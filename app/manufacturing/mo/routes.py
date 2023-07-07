from flask import Blueprint, flash, render_template, redirect, request, url_for
from app.db import connect


bp = Blueprint('mo', __name__, template_folder='templates')

@bp.route('/manufacturing/mos')
def get_mos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done \
                , mo.bom_id, mo.status, product.id, product.name, product.price \
                FROM mo JOIN bom ON mo.bom_id = bom.id \
                JOIN product ON bom.product_id = product.id"
                )
    

    mos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('mo_list.html', mos=mos)

@bp.route('/manufacturing/mos/<int:id>', methods=['GET', 'POST'])
def get_mo(id):
    if request.method == 'POST':
        status = request.form.get('status')
        conn = connect()
        cursor = conn.cursor()
        cursor.execute("UPDATE mo SET status = %s WHERE id = %s", (status, id))
        conn.commit()
        cursor.close()
        conn.close()

    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done, mo.bom_id, mo.status, product.id, product.name, product.price \
                   FROM mo JOIN bom ON mo.bom_id = bom.id \
                   JOIN product ON bom.product_id = product.id \
                   WHERE mo.id = %s", (id,))
    
    mo = cursor.fetchone()

    cursor.execute("SELECT bom_line.id, \
                           bom_line.bom_id, \
                           bom_line.component_id, \
                           product.name, \
                           bom_line.quantity, \
                           product.price, \
                          (SELECT COUNT(*) FROM inventory_item \
                           WHERE product_id = bom_line.component_id \
                           AND location = 'Warehouse') AS available_count \
                           FROM bom_line \
                           JOIN \
                           mo ON bom_line.bom_id = mo.bom_id \
                           JOIN \
                           product ON bom_line.component_id = product.id \
                           WHERE mo.id = %s", (id,))
    
    bom_lines = cursor.fetchall()
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