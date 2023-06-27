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

    #cursor.execute("SELECT * FROM bom WHERE id = %s", (id,))
    cursor.execute("SELECT bom.id, product.id, product.name \
                   FROM bom JOIN product ON bom.product_id = product.id \
                   WHERE bom.id = %s", (id,))

    bom = cursor.fetchone()

    print(bom)

    cursor.close()
    conn.close()

    return render_template('bom_detail.html', bom=bom)