from flask import Blueprint, render_template, redirect, request, url_for
from app.db import connect

bp = Blueprint('supplier', __name__, template_folder='templates')

@bp.route('/purchase/suppliers')
def get_suppliers():
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM supplier")
    suppliers = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('supplier_list.html', suppliers=suppliers)

@bp.route('/purchase/suppliers/<int:id>')
def get_supplier(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM supplier WHERE id = %s", (id,))
    supplier = cursor.fetchone()

    cursor.close()
    conn.close()

    return render_template('supplier_detail.html', supplier=supplier)

@bp.route('/purchase/suppliers/')
def redirect_to_products():
    return redirect(url_for('supplier.get_suppliers'))


@bp.route('/purchase/suppliers/create', methods=['GET', 'POST'])
def create_supplier():
    print("CREATE SUPPLIER")
    if request.method == 'POST':
        print("CREATE SUPPLIER -- POST")
        name = request.form['name']
        contact = request.form['contact']

        conn = connect()
        cursor = conn.cursor()

        cursor.execute("INSERT INTO supplier (name, contact) VALUES (%s, %s)", (name, contact))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('supplier.get_suppliers'))

    return render_template('create_supplier.html')

@bp.route('/purchase/suppliers/update/<int:id>', methods=['GET', 'POST'])
def update_supplier(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM supplier WHERE id = %s", (id,))
    supplier = cursor.fetchone()

    if request.method == 'POST':
        name = request.form['name']
        contact = request.form['contact']

        cursor.execute("UPDATE supplier SET name = %s, contact = %s WHERE id = %s", (name, contact, id))
        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for('supplier.get_suppliers'))

    return render_template('create_supplier.html', supplier=supplier)

@bp.route('/purchase/suppliers/delete/<int:id>', methods=['POST'])
def delete_supplier(id):
    conn = connect()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM supplier WHERE id = %s", (id,))
    conn.commit()

    cursor.close()
    conn.close()

    return redirect(url_for('supplier.get_suppliers'))

