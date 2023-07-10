from flask import Blueprint, flash, render_template, redirect, request, session, url_for
from app.db import connect


bp = Blueprint('mo', __name__, template_folder='templates')

@bp.route('/manufacturing/mos')
def get_mos():
    conn = connect()
    cursor = conn.cursor()

    selected_status = request.args.get('status')
    selected_bom = request.args.get('bom')
    selected_filter_type = request.args.get('filter_type')

    query = """SELECT mo.id, mo.date_created, mo.date_done \
                , mo.bom_id, mo.status, product.id, product.name, product.price \
                FROM mo JOIN bom ON mo.bom_id = bom.id \
                JOIN product ON bom.product_id = product.id
                WHERE 1=1"""
    
    params = []
    
    if selected_status:
        query += " AND mo.status = %s"
        params.append(selected_status)

    if selected_bom:
        if selected_filter_type == 'AND':
            query += " AND mo.bom_id = %s"
        elif selected_filter_type == 'OR':
            query += " OR mo.bom_id = %s"

        params.append(selected_bom)

    cursor.execute(query, params)
    mos = cursor.fetchall()

    # Retrieve the boms and statuses
    cursor.execute("""SELECT bom.id, bom.product_id, product.name
                   FROM bom JOIN product ON bom.product_id = product.id
                   WHERE product.is_assembly = True
                   ORDER BY product.name""")
    boms = cursor.fetchall()

    status_query = "SELECT enumlabel FROM pg_enum WHERE enumtypid = 'mo_status'::regtype"
    cursor.execute(status_query)
    statuses = [row[0] for row in cursor.fetchall()]

    cursor.close()
    conn.close()

    cursor.close()
    conn.close()

    return render_template(
        'mo_list.html', 
        mos=mos,
        boms=boms,
        statuses=statuses,
        selected_bom=selected_bom,
        selected_status=selected_status,
        selected_filter_type=selected_filter_type
        )

@bp.route('/manufacturing/mos/<int:id>', methods=['GET', 'POST'])
def get_mo(id):
    if request.method == 'POST':
        status = request.form.get('status')
        conn = connect()
        cursor = conn.cursor()
        cursor.execute("UPDATE mo SET status = %s WHERE id = %s", (status, id))
        conn.commit()
        if status == 'Reserved':
            mo = session.get('mo')
            if mo:
                mo_id = mo[0]
            bom_lines = session.get('bom_lines', [])
            print("BOM Lines inside POST:", bom_lines)
            for bom_line in bom_lines:
                print("BOM Line :", bom_line)
                component_id = bom_line[2]
                quantity = bom_line[4]

                print("Component ID:", component_id)
                print("Quantity:", quantity)

                cursor.execute("UPDATE inventory_item \
                                SET location = 'Factory', mo_id = %s\
                                WHERE product_id = %s \
                                AND location = 'Warehouse' \
                                AND id IN (SELECT id FROM inventory_item WHERE product_id = %s AND location = 'Warehouse' LIMIT %s)",
                                (mo_id, component_id, component_id, quantity))
                
                flash(f'{quantity} items were reserved successfully.', 'success')
                conn.commit()

                # Retrieve the updated inventory_item_ids after the update query
                cursor.execute(
                    "SELECT id FROM inventory_item \
                    WHERE product_id = %s AND location = 'Factory' \
                    AND id IN (SELECT id FROM inventory_item WHERE product_id = %s AND location = 'Factory' LIMIT %s)",
                    (component_id, component_id, quantity)
                )
                inventory_item_ids = cursor.fetchall()
                for inventory_item_id in inventory_item_ids:
                    print("Inserting stock_move for inventory_item_id:", inventory_item_id[0])
                    try:
                        cursor.execute("INSERT INTO stock_move (inventory_item_id, source_location, destination_location, move_date) \
                        VALUES (%s, 'Warehouse', 'Factory', now())", (inventory_item_id[0],))
                        conn.commit()
                        print("Stock_move inserted successfully.")
                    except Exception as e:
                         print("Error inserting stock_move:", str(e))

                conn.commit()

        if status == 'Cancelled':
            # Check if MO was reserved before cancellation
            cursor.execute("SELECT bom_id FROM mo WHERE id = %s", (id,))
            bom_id = cursor.fetchone()[0]

            cursor.execute("SELECT COUNT(*) FROM inventory_item WHERE location = 'Factory' AND mo_id = %s", (id,))
            reserved_count = cursor.fetchone()[0]

            if bom_id is not None and reserved_count > 0:
                # Create reverse stock moves for the cancelled MO
                cursor.execute("INSERT INTO stock_move (inventory_item_id, source_location, destination_location, move_date) \
                        SELECT id, 'Factory', 'Warehouse', now() \
                        FROM inventory_item \
                        WHERE location = 'Factory' AND mo_id = %s", (id,))
                conn.commit()

                # Update inventory items reserved for the cancelled MO
                cursor.execute("UPDATE inventory_item SET location = 'Warehouse', mo_id = NULL WHERE location = 'Factory' AND mo_id = %s", (id,))
                conn.commit()
                flash(f'{reserved_count} items were unreserved successfully.', 'success')
        
        cursor.close()
        conn.close()

    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done, mo.bom_id, mo.status, \
                    product.id, product.name, product.price \
                    FROM mo \
                    JOIN bom ON mo.bom_id = bom.id \
                    JOIN product ON bom.product_id = product.id \
                    WHERE mo.id = %s", (id,))

    mo = cursor.fetchone()
    
    session['mo'] = mo

    cursor.execute("""
        SELECT bom_line.id, bom_line.bom_id, bom_line.component_id, product.name,
        bom_line.quantity, product.price,
        (SELECT COUNT(*) FROM inventory_item
         WHERE product_id = bom_line.component_id
         AND location = 'Warehouse') AS available_count,
        COUNT(inventory_item.id) AS reserved_item_count
        FROM bom_line
        JOIN product ON bom_line.component_id = product.id
        LEFT JOIN inventory_item ON bom_line.component_id = inventory_item.product_id
            AND inventory_item.mo_id = %s
        WHERE bom_line.bom_id = %s
        GROUP BY bom_line.id, bom_line.bom_id, bom_line.component_id, product.name, bom_line.quantity, product.price
    """, (mo[0], mo[3]))

    bom_lines = cursor.fetchall()
    
    session['bom_lines'] = bom_lines

    print("BOM Lines inside GET:", bom_lines)
    components_cost = sum(bom_line[5] * bom_line[4] for bom_line in bom_lines)

    cursor.close()
    conn.close()

    return render_template('mo_detail.html', mo=mo, bom_lines=bom_lines, components_cost=components_cost)


@bp.route('/manufacturing/mos/')
def redirect_to_products():
    return redirect(url_for('mo.get_mos'))

@bp.route('/manufacturing/mos/create', methods=['GET', 'POST'])
def create_mo():
    if request.method == 'POST':
        # Retrieve form data
        bom_id = request.form.get('bom_id')

        # Create a new PO
        conn = connect()
        cursor = conn.cursor()

        # Insert the new PO into the database
        cursor.execute("INSERT INTO mo (bom_id) VALUES (%s) RETURNING id", (bom_id,))

        mo_id = cursor.fetchone()[0]

        cursor.close()
        conn.commit()
        conn.close()

        return redirect(url_for('mo.get_mo', id=mo_id))

    # Retrieve the list of boms as soon as '/create' route is accessed
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT bom.id, bom.product_id, product.name FROM bom \
                   JOIN product on bom.product_id = product.id \
                   WHERE product.is_assembly = True")
    boms = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('mo_create.html', boms=boms)

@bp.route('/manufacturing/mos/<int:id>/delete', methods=['POST'])
def delete_mo(id):
    conn = connect()
    cursor = conn.cursor()

    # Retrieve the MO's status
    cursor.execute("SELECT status FROM mo WHERE id = %s", (id,))
    mo_status = cursor.fetchone()[0]

    if mo_status == 'Cancelled':
        cursor.execute("DELETE FROM mo WHERE id = %s", (id,))
        conn.commit()
        flash('MO was deleted successfully.', 'success')


    cursor.close()
    conn.close()

    return redirect(url_for('mo.get_mos'))