from flask import Blueprint, render_template


bp = Blueprint('supplier2', __name__, template_folder='templates')

@bp.route('/purchase2/suppliers2')
def get_suppliers2():
    return render_template('supplier2_list.html')


