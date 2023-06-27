from flask import Blueprint, render_template
from app.db import connect

bp = Blueprint('bom', __name__, template_folder='templates')

@bp.route('/boms')
def get_boms():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM bom")
    boms = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('bom_list.html', boms=boms)

@bp.route('/boms/<int:id>')
def get_bom(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT bom.id, product.id, product.name \
                   FROM bom JOIN product ON bom.product_id = product.id \
                   WHERE bom.id = %s", (id,))

    bom = cursor.fetchone()

    cursor.execute("SELECT bom_line.id, bom_line.bom_id, bom_line.component_id, \
                   product.name, bom_line.quantity \
                   FROM bom_line JOIN product ON bom_line.component_id = product.id \
                   WHERE bom_line.bom_id = %s", (id,))

    bom_lines = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('bom_detail.html', bom=bom, bom_lines=bom_lines)