from flask import Blueprint, flash, render_template, redirect, request, url_for
from app.db import connect
bp = Blueprint('po', __name__, template_folder='templates')

@bp.route('/purchase/pos')
def get_pos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, created_date, received_date, status, supplier_id FROM po")
    pos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_list.html', pos=pos)

@bp.route('/purchase/pos/<int:id>', methods=['GET'])
def get_po(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, created_date, received_date, status, supplier_id FROM po WHERE id = %s", (id,))
    po = cursor.fetchone()

    cursor.execute("SELECT po_line.id, po_line.po_id, po_line.product_id, \
                   product.name, po_line.quantity, product.price \
                   FROM po_line JOIN product ON po_line.product_id = product.id \
                   WHERE po_line.po_id = %s", (id,))

    po_lines = cursor.fetchall()
    total = sum(po_line[5] * po_line[4] for po_line in po_lines)

    cursor.execute("SELECT id, name FROM product")
    products = cursor.fetchall()

    cursor.execute("SELECT id, name FROM supplier")  # Retrieve suppliers
    suppliers = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_detail.html', po=po, po_lines=po_lines, total=total, products=products, suppliers=suppliers)

@bp.route('/purchase/pos/')
def redirect_to_products():
    return redirect(url_for('po.get_pos'))


@bp.route('/purchase/pos/create', methods=['GET', 'POST'])
def create_po():
    if request.method == 'POST':
        # Retrieve form data
        supplier_id = request.form.get('supplier_id')

        # Create a new PO
        conn = connect()
        cursor = conn.cursor()

        # Insert the new PO into the database
        cursor.execute("INSERT INTO po (supplier_id) VALUES (%s) RETURNING id", (supplier_id,))

        po_id = cursor.fetchone()[0]

        cursor.close()
        conn.commit()
        conn.close()

        return redirect(url_for('po.get_po', id=po_id))

    # Retrieve the list of suppliers as soon as /create route is accessed
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, name FROM supplier")
    suppliers = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_create.html', suppliers=suppliers)

@bp.route('/purchase/pos/<int:po_id>/delete', methods=['POST'])
def delete_po(po_id):
    conn = connect()
    cursor = conn.cursor()

    # Retrieve the PO's status
    cursor.execute("SELECT status FROM po WHERE id = %s", (po_id,))
    po_status = cursor.fetchone()[0]

    # Check if the PO status is "Cancelled"
    if po_status == 'Cancelled':
        # Delete the associated PO Lines
        cursor.execute("DELETE FROM po_line WHERE po_id = %s", (po_id,))

        # Delete the PO
        cursor.execute("DELETE FROM po WHERE id = %s", (po_id,))
        conn.commit()

        flash('PO and associated PO Lines deleted successfully.', 'success')
    else:
        flash('PO can only be deleted if its status is "Cancelled".', 'error')

    cursor.close()
    conn.close()

    return redirect(url_for('po.get_pos'))


@bp.route('/purchase/pos/<int:id>/add_po_line', methods=['POST'])
def add_po_line(id):
    if request.method == 'POST':
        product_id = request.form.get('product_id')
        quantity = request.form.get('quantity')

        # Retrieve the PO based on the provided ID
        conn = connect()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM po WHERE id = %s", (id,))
        po = cursor.fetchone()

        if po is None:
            # Handle the case where the PO is not found
            # ...

            cursor.close()
            conn.close()
            return redirect(url_for('po.get_pos'))

        # Insert the PO line into the database
        cursor.execute("INSERT INTO po_line (po_id, product_id, quantity) VALUES (%s, %s, %s)",
                       (id, product_id, quantity))

        cursor.close()
        conn.commit()
        conn.close()

    return redirect(url_for('po.get_po', id=id))

@bp.route('/purchase/pos/<int:po_id>/delete_po_line/<int:po_line_id>', methods=['POST'])
def delete_po_line(po_id, po_line_id):
    if request.method == 'POST':
        conn = connect()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM po_line WHERE id = %s", (po_line_id,))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('po.get_po', id=po_id))


@bp.route('/purchase/pos/<int:id>/set_status', methods=['POST'])
def set_status(id):
    status = request.form.get('status')

    conn = connect()
    cursor = conn.cursor()

    # Update the PO status
    cursor.execute("UPDATE po SET status = %s WHERE id = %s", (status, id))

    # Retrieve the updated PO information
    cursor.execute("SELECT id, created_date, received_date, status, supplier_id FROM po WHERE id = %s", (id,))
    po = cursor.fetchone()

    # Retrieve the PO lines
    cursor.execute("SELECT po_line.id, po_line.po_id, po_line.product_id, \
                   product.name, po_line.quantity, product.price \
                   FROM po_line JOIN product ON po_line.product_id = product.id \
                   WHERE po_line.po_id = %s", (id,))
    po_lines = cursor.fetchall()

    # Calculate the total
    total = sum(po_line[5] * po_line[4] for po_line in po_lines)

    if status == "Completed":
        for po_line in po_lines:
            product_id = po_line[2]
            quantity = po_line[4]

            # Iterate over the quantity
            for _ in range(quantity):
                # Create inventory_item record for each item
                cursor.execute("INSERT INTO inventory_item (product_id, serial_number, location, po_line_id) VALUES (%s, uuid_generate_v4(), 'Warehouse', %s) RETURNING id", (product_id, po_line[0]))
                inventory_item_id = cursor.fetchone()[0]
                cursor.execute("INSERT INTO stock_move (inventory_item_id, source_location, destination_location, move_date) VALUES (%s, 'Customer', 'Warehouse', now())", (inventory_item_id,))

    cursor.close()
    conn.commit()
    conn.close()

    return render_template('po_detail.html', po=po, po_lines=po_lines, total=total)

@bp.route('/purchase/pos/<int:id>/update_supplier', methods=['POST'])
def update_supplier(id):
    supplier_id = request.form.get('supplier_id')

    conn = connect()
    cursor = conn.cursor()

    # Update the supplier ID for the PO
    cursor.execute("UPDATE po SET supplier_id = %s WHERE id = %s", (supplier_id, id))

    cursor.close()
    conn.commit()
    conn.close()

    return redirect(url_for('po.get_po', id=id))