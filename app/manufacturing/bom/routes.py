from flask import Blueprint, flash, render_template, redirect, request, url_for
from app.db import connect

bp = Blueprint('bom', __name__, template_folder='templates')

@bp.route('/manufacturing/boms')
def get_boms():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM bom")
    boms = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('bom_list.html', boms=boms)

@bp.route('/manufacturing/boms/<int:id>')
def get_bom(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT bom.id, product.id, product.name \
                   FROM bom JOIN product ON bom.product_id = product.id \
                   WHERE bom.id = %s", (id,))

    bom = cursor.fetchone()

    cursor.execute("SELECT bom_line.id, bom_line.bom_id, bom_line.component_id, \
                   product.name, bom_line.quantity, product.price \
                   FROM bom_line JOIN product ON bom_line.component_id = product.id \
                   WHERE bom_line.bom_id = %s", (id,))

    bom_lines = cursor.fetchall()
    components_cost = sum(bom_line[5] * bom_line[4] for bom_line in bom_lines)

    cursor.execute("SELECT id, name FROM product")
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('bom_detail.html', 
                           bom=bom, 
                           bom_lines=bom_lines, 
                           components_cost=components_cost, 
                           products=products)

@bp.route('/manufacturing/boms/')
def redirect_to_products():
    return redirect(url_for('bom.get_boms'))

@bp.route('/manufacturing/boms/create', methods=['GET', 'POST'])
def create_bom():
    if request.method == 'POST':
        # Retrieve product from form
        product_id = request.form.get('product_id')

        conn = connect()
        cursor = conn.cursor()

        # Insert new BOM into the database
        cursor.execute("INSERT INTO bom (product_id) VALUES (%s) RETURNING id", (product_id,))

        bom_id = cursor.fetchone()[0]

        cursor.close()
        conn.commit()
        conn.close()

        return redirect(url_for('bom.get_bom', id=bom_id))
    
    # Retrieve the list of products as soon as /create route is accessed
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, name FROM product")
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('bom_create.html', products=products)

@bp.route('/manufacturing/boms/<int:id>/delete', methods=['POST'])
def delete_bom(id):
    conn = connect()
    cursor = conn.cursor()

    # Check if there is an MO where this BoM is used
    cursor.execute("SELECT * FROM mo WHERE bom_id = %s", (id,))
    mo = cursor.fetchone()

    if mo:
        flash(f'BOM cannot be deleted because it is used in MO {mo[0]} ', 'error')
    else:
        # Delete the associated BoM Lines
        cursor.execute("DELETE FROM bom_line WHERE bom_id = %s", (id,))

        # Delete the BoM
        cursor.execute("DELETE FROM bom WHERE id = %s", (id,))
        conn.commit()

        flash('BoM and associated BoM Lines deleted successfully.', 'success')
        
    cursor.close()
    conn.close()

    return redirect(url_for('bom.get_boms'))

@bp.route('/manufacturing/boms/<int:id>/add_bom_line', methods=['POST'])
def add_bom_line(id):
    if request.method == 'POST':
        component_id = request.form.get('component_id')
        quantity = request.form.get('quantity')

        # Retrieve the BOM based on the provided ID
        conn = connect()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM bom WHERE id = %s", (id,))
        bom = cursor.fetchone()

        if bom is None:
            # Handle the case where the PO is not found
            # ...

            cursor.close()
            conn.close()
            return redirect(url_for('bom.get_boms'))

        # Insert the BoM line into the database
        cursor.execute("INSERT INTO bom_line (bom_id, component_id, quantity) VALUES (%s, %s, %s)",
                       (id, component_id, quantity))

        cursor.close()
        conn.commit()
        conn.close()

    return redirect(url_for('bom.get_bom', id=id))

@bp.route('/manufacturing/boms/<int:bom_id>/delete_bom_line/<int:bom_line_id>', methods=['POST'])
def delete_bom_line(bom_id, bom_line_id):
    if request.method == 'POST':
        conn = connect()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM bom_line WHERE id = %s", (bom_line_id,))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('bom.get_bom', id=bom_id))