from flask import Blueprint, render_template
from app.db import connect


bp = Blueprint('mo', __name__, template_folder='templates')

@bp.route('/mos')
def get_mos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT id, date_created, date_done, bom_id, status FROM mo")
    mos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('mo_list.html', mos=mos)

@bp.route('/mos/<int:id>')
def get_mo(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done, mo.bom_id, mo.status  \
                   FROM mo JOIN bom ON mo.bom_id = bom.id \
                   WHERE mo.id = %s", (id,))

    mo = cursor.fetchone()

    cursor.execute("SELECT bom_line.id, bom_line.bom_id, bom_line.component_id, \
                   product.name, bom_line.quantity \
                   FROM bom_line JOIN mo ON bom_line.bom_id = mo.bom_id \
                   JOIN product ON bom_line.component_id = product.id \
                   WHERE mo.id = %s", (id,))

    bom_lines = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('mo_detail.html', mo=mo, bom_lines=bom_lines)