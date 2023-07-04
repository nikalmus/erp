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
    if request.method == 'POST':
        # Process the form submission and create a new supplier
        name = request.form.get('name')
        email = request.form.get('email')

        conn = connect()
        cursor = conn.cursor()

        # Insert the new supplier into the database
        cursor.execute("INSERT INTO supplier (name, email) VALUES (%s, %s)", (name, email))
        conn.commit()

        cursor.close()
        conn.close()

        # Redirect to the supplier list page
        return redirect(url_for('supplier.get_suppliers'))

    return render_template('create_supplier.html')