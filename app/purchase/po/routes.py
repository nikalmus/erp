from flask import Blueprint, render_template, redirect, url_for
from app.db import connect

bp = Blueprint('po', __name__, template_folder='templates')

@bp.route('/purchase/pos')
def get_pos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM po")
    pos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('po_list.html', pos=pos)

@bp.route('/purchase/pos/<int:id>')
def get_po(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM po WHERE id = %s", (id,))
    po = cursor.fetchone()

    cursor.execute("SELECT po_line.id, po_line.po_id, po_line.product_id, \
                   product.name, po_line.quantity, product.price \
                   FROM po_line JOIN product ON po_line.product_id = product.id \
                   WHERE po_line.po_id = %s", (id,))

    po_lines = cursor.fetchall()
    total = sum(po_line[5] * po_line[4] for po_line in po_lines)

    cursor.close()
    conn.close()

    return render_template('po_detail.html', po=po, po_lines=po_lines, total=total)

@bp.route('/purchase/pos/')
def redirect_to_products():
    return redirect(url_for('po.get_pos'))