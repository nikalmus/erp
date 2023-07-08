from flask import Blueprint, flash, render_template, redirect, request, url_for
from app.db import connect

bp = Blueprint('products', __name__, template_folder='templates')

@bp.route('/manufacturing/products')
def get_products():
    conn = connect()  
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM product")
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('product_list.html', products=products)

@bp.route('/manufacturing/products/<int:id>')
def get_product(id):
    conn = connect()  
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM product WHERE id = %s", (id,))
    product = cursor.fetchone()

    cursor.close()
    conn.close()

    return render_template('product_detail.html', product=product)

@bp.route('/manufacturing/products/')
def redirect_to_products():
    return redirect(url_for('products.get_products'))

@bp.route('/manufacturing/products/create', methods=['GET', 'POST'])
def create_product():
    if request.method == 'POST':
        print("PRODUCT CREATE...")
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        is_assembly = request.form['is_assembly']

        conn = connect()
        cursor = conn.cursor()

        cursor.execute("INSERT INTO product (name, description, price, is_assembly) \
                       VALUES (%s, %s, %s, %s)", (name, description, price, is_assembly))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('products.get_products'))

    return render_template('product_create.html')

@bp.route('/manufacturing/products/update/<int:id>', methods=['GET', 'POST'])
def update_product(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM product WHERE id = %s", (id,))
    product = cursor.fetchone()

    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        is_assembly = request.form['is_assembly']

        cursor.execute("UPDATE product \
                       SET name = %s, \
                       description = %s, \
                       price = %s, \
                       is_assembly = %s \
                       WHERE id = %s", (name, description, price, is_assembly, id))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('products.get_products'))

    return render_template('product_create.html', product=product)

@bp.route('/manufacturing/products/delete/<int:id>', methods=['POST'])
def delete_product(id):
    conn = connect()
    cursor = conn.cursor()

    # Check if there is a PO Line where this product is used
    cursor.execute("SELECT id FROM po_line WHERE product_id = %s", (id,))
    po_line = cursor.fetchone()
    if po_line:
        flash(f'Product cannot be deleted because it is used in PO Line {po_line[0]} ', 'error')
    else:
        # Check if there is a BoM where this assembly is used 
        cursor.execute("SELECT id FROM bom WHERE product_id = %s", (id,))
        bom = cursor.fetchone()
        if bom:
            flash(f'Product cannot be deleted because it is used in BoM {bom[0]} ', 'error')
        else:
            cursor.execute("DELETE FROM product WHERE id = %s", (id,))
            conn.commit()

    cursor.close()
    conn.close()

    return redirect(url_for('products.get_products'))