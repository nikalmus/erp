import csv
from decimal import Decimal
from flask import Blueprint, flash, render_template, redirect, request, url_for
from app.db import connect

bp = Blueprint('products', __name__, template_folder='templates')

@bp.route('/manufacturing/products')
def get_products():
    conn = connect()
    cursor = conn.cursor()

    search = request.args.get('search', default='')
    sort = request.args.get('sort', default='name')

    query = "SELECT * FROM product"

    if search:
        query += " WHERE name ILIKE %s"
        params = ['%' + search + '%']
        cursor.execute(query, params)
    else:
        cursor.execute(query)

    products = cursor.fetchall()

    if sort == 'name':
        products = sorted(products, key=lambda product: product[1])  
    elif sort == 'price_asc':
        products = sorted(products, key=lambda product: (Decimal(0) if product[3] is None else product[3], product[1]))
    elif sort == 'price_desc':
        products = sorted(products, key=lambda product: (Decimal('-Infinity') if product[3] is None else -product[3], product[1]))  

    cursor.close()
    conn.close()

    return render_template('product_list.html', products=products, search=search, sort=sort)


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
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        is_assembly = request.form['is_assembly']

        conn = connect()
        cursor = conn.cursor()

        # Check if the product already exists in the database by name
        cursor.execute("SELECT COUNT(*) FROM product WHERE name = %s", (name,))
        count = cursor.fetchone()[0]
        if count > 0:
            flash('Product with the same name already exists.')
            return redirect(url_for('products.create_product'))

        if is_assembly == 'false' and (not price.strip() or price.strip() == ''):
            flash('Price is required for non-assembly products.')
            return redirect(url_for('products.create_product'))

        # Add server-side check for empty string
        if not price.strip() or price.strip() == '':
            price = None


        if price is None:
            cursor.execute("INSERT INTO product (name, description, is_assembly) \
                            VALUES (%s, %s, %s)", (name, description, is_assembly))
        else:
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

        if is_assembly == 'false' and not price.strip():
            flash('Price is required for non-assembly products.', 'error')
            return redirect(url_for('products.update_product', id=id))

        if not price.strip() or price.strip() == '':
            price = None
        else:
            try:
                price = float(price)
            except ValueError:
                flash('Invalid price format. Please enter a valid number.', 'error')
                return redirect(url_for('products.update_product', id=id))


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

@bp.route('/manufacturing/products/import', methods=['GET', 'POST'])
def import_csv():
    if request.method == 'POST':
        if 'csv_file' in request.files:
            csv_file = request.files['csv_file']
            if csv_file.filename.endswith('.csv'):
                csv_reader = csv.reader(csv_file.stream.read().decode('utf-8-sig').splitlines())
                next(csv_reader)  # Skip the header row

                conn = connect()
                cursor = conn.cursor()

                for row in csv_reader:
                    name = row[0]
                    description = row[1]
                    price = row[2]
                    is_assembly = row[3]

                    # Check if the product already exists in the database by name
                    cursor.execute("SELECT COUNT(*) FROM product WHERE name = %s", (name,))
                    count = cursor.fetchone()[0]

                    if count == 0:  # Product with the same name doesn't exist, insert it
                        cursor.execute("INSERT INTO product (name, description, price, is_assembly) \
                                        VALUES (%s, %s, %s, %s)", (name, description, price, is_assembly))

                conn.commit()

                cursor.close()
                conn.close()

                return redirect(url_for('products.get_products'))

    return redirect(url_for('products.get_products'))