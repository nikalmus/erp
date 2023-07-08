from flask import Blueprint, render_template

bp = Blueprint('purchase', __name__, url_prefix='/purchase/', template_folder='templates')

from app.purchase.po import routes
from app.purchase.supplier import routes


@bp.route('/', methods=['GET'])
def purchase_home():
    return render_template('purchase.html')