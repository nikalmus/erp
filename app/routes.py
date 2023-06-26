from flask import Blueprint, render_template

bp = Blueprint('routes', __name__)

@bp.route('/')
def index():
    return 'Hello, ERP'

@bp.route('/list')
def list_list():
    items = ['Item 1', 'Item 2', 'Item 3']
    return '\n'.join(items)

@bp.route('/items')
def list_items():
    items = ['Item 1', 'Item 2', 'Item 3']
    return render_template('items.html', items=items)
    

