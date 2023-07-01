from flask import Blueprint, render_template, redirect, url_for
from app.db import connect

bp = Blueprint('item', __name__, template_folder='templates')

@bp.route('/inventory/inventory_items')
def get_inventory_items():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM inventory_item")
    inventory_items = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('inventory_item_list.html', inventory_items=inventory_items)

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