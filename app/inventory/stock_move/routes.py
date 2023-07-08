from flask import Blueprint, render_template, redirect, url_for
from app.db import connect

bp = Blueprint('stock_move', __name__, template_folder='templates')

@bp.route('/inventory/stock_moves')
def get_stock_moves():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM stock_move")
    stock_moves = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('stock_move_list.html', stock_moves=stock_moves)

@bp.route('/inventory/stock_moves/<int:id>')
def get_stock_move(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT move.id, move.inventory_item_id, move.source_location, \
                          move.destination_location, move.move_date, item.product_id, product.name \
                          FROM stock_move AS move JOIN inventory_item AS item \
                          ON item.id = move.inventory_item_id JOIN product \
                          ON product.id = item.product_id \
                          WHERE move.id = %s", (id,))
    
    stock_move = cursor.fetchone()
    cursor.close()
    conn.close()

    return render_template('stock_move_detail.html', stock_move=stock_move)