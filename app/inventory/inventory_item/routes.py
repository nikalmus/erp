from flask import Blueprint, render_template, redirect, request, url_for
from app.db import connect

bp = Blueprint('item', __name__, template_folder='templates')


@bp.route('/inventory/inventory_items')
def get_inventory_items():
    conn = connect()
    cursor = conn.cursor()

    selected_product = request.args.get('product')
    selected_location = request.args.get('location')
    selected_filter_type = request.args.get('filter_type')

    print(f"SELECTED PROD {selected_product}")

    query = """SELECT item.id, item.product_id, item.serial_number, item.location, product.name 
               FROM inventory_item AS item 
               JOIN product ON item.product_id = product.id
               WHERE 1=1"""

    params = []

    if selected_product:
        query += " AND item.product_id = %s"
        params.append(selected_product)

    if selected_location:
        if selected_filter_type == 'AND':
            query += " AND item.location = %s"
        elif selected_filter_type == 'OR':
            query += " OR item.location = %s"

        params.append(selected_location)

    cursor.execute(query, params)
    inventory_items = cursor.fetchall()

    # Retrieve the products and locations
    cursor.execute("SELECT id, name FROM product ORDER BY name")
    products = cursor.fetchall()

    location_query = "SELECT enumlabel FROM pg_enum WHERE enumtypid = 'location_type'::regtype"
    cursor.execute(location_query)
    locations = [row[0] for row in cursor.fetchall()]
    
    cursor.close()
    conn.close()

    return render_template(
        'inventory_item_list.html',
        inventory_items=inventory_items,
        products=products,  
        locations=locations,
        selected_product=selected_product,
        selected_location=selected_location,
        selected_filter_type=selected_filter_type
    )


@bp.route('/inventory/inventory_items/<int:id>')
def get_inventory_item(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT item.id, item.product_id, item.serial_number, item.location, product.name \
                   FROM inventory_item AS item JOIN product ON item.product_id = product.id \
                   WHERE item.id = %s", (id,))

    inventory_item = cursor.fetchone()

    cursor.close()
    conn.close()

    return render_template('inventory_item_detail.html', inventory_item=inventory_item)

@bp.route('/inventory/inventory_items/')
def redirect_to_products():
    return redirect(url_for('item.get_inventory_items'))