from flask import Blueprint, render_template

bp = Blueprint('purchase2', __name__, url_prefix='/purchase2/', template_folder='templates')

from app.purchase2.supplier2 import routes


@bp.route('/', methods=['GET'])
def purchase2_home():
    return render_template('purchase2.html')