from flask import Blueprint, render_template, redirect, url_for
from app.db import connect


bp = Blueprint('mo', __name__, template_folder='templates')

@bp.route('/manufacturing/mos')
def get_mos():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done \
                , mo.bom_id, mo.status, product.id, product.name, product.price \
                FROM mo JOIN bom ON mo.bom_id = bom.id \
                JOIN product ON bom.product_id = product.id"
                )
    

    mos = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('mo_list.html', mos=mos)

@bp.route('/manufacturing/mos/<int:id>')
def get_mo(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT mo.id, mo.date_created, mo.date_done \
                   , mo.bom_id, mo.status, product.id, product.name, product.price  \
                   FROM mo JOIN bom ON mo.bom_id = bom.id \
                   JOIN product ON bom.product_id = product.id \
                   WHERE mo.id = %s", (id,))

    mo = cursor.fetchone()

    cursor.execute("SELECT bom_line.id, bom_line.bom_id, bom_line.component_id, \
                   product.name, bom_line.quantity, product.price \
                   FROM bom_line JOIN mo ON bom_line.bom_id = mo.bom_id \
                   JOIN product ON bom_line.component_id = product.id \
                   WHERE mo.id = %s", (id,))

    bom_lines = cursor.fetchall()
    components_cost = sum(bom_line[5] * bom_line[4] for bom_line in bom_lines)

    cursor.close()
    conn.close()

    return render_template('mo_detail.html', mo=mo, bom_lines=bom_lines, components_cost=components_cost)


@bp.route('/manufacturing/mos/')
def redirect_to_products():
    return redirect(url_for('mo.get_mos'))