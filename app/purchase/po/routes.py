from flask import Blueprint, render_template, redirect, request, url_for
from app.db import connect
bp = Blueprint('po', __name__, template_folder='templates')

@bp.route('/purchase/pos')
def get_pos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, created_date, purchase_date, status, supplier_id FROM po")
    pos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_list.html', pos=pos)

@bp.route('/purchase/pos/<int:id>', methods=['GET'])
def get_po(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, created_date, purchase_date, status, supplier_id FROM po WHERE id = %s", (id,))
    po = cursor.fetchone()

    cursor.execute("SELECT po_line.id, po_line.po_id, po_line.product_id, \
                   product.name, po_line.quantity, product.price \
                   FROM po_line JOIN product ON po_line.product_id = product.id \
                   WHERE po_line.po_id = %s", (id,))

    po_lines = cursor.fetchall()
    total = sum(po_line[5] * po_line[4] for po_line in po_lines)

    cursor.execute("SELECT id, name FROM product")
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_detail.html', po=po, po_lines=po_lines, total=total, products=products)

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

@bp.route('/purchase/pos/<int:id>/add_line', methods=['POST'])
def add_po_line(id):
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
        return redirect(url_for('po.list_pos'))

    # Insert the PO line into the database
    cursor.execute("INSERT INTO po_line (po_id, product_id, quantity) VALUES (%s, %s, %s)",
                   (id, product_id, quantity))

    cursor.close()
    conn.commit()
    conn.close()

    return redirect(url_for('po.get_po', id=id))

@bp.route('/purchase/pos/<int:id>/set_status', methods=['POST'])
def set_status(id):
    status = request.form.get('status')

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
        return redirect(url_for('po.list_pos'))

    # Update the status of the PO
    cursor.execute("UPDATE po SET status = %s WHERE id = %s", (status, id))

    cursor.close()
    conn.commit()
    conn.close()

    return redirect(url_for('po.get_po', id=id))