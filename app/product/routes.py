from flask import Blueprint, render_template
from app.db import connect

bp = Blueprint('products', __name__, template_folder='templates')

@bp.route('/products')
def get_products():
    conn = connect()  
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM product")
    products = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('product_list.html', products=products)

@bp.route('/products/<int:id>')
def get_product(id):
    conn = connect()  
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM product WHERE id = %s", (id,))
    product = cursor.fetchone()

    print(product) 

    cursor.close()
    conn.close()

    return render_template('product_detail.html', product=product)