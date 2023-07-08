from flask import Blueprint, render_template

bp = Blueprint('manufacturing', __name__, url_prefix='/manufacturing/', template_folder='templates')

from app.manufacturing.product import routes
from app.manufacturing.bom import routes
from app.manufacturing.mo import routes
from app.manufacturing import bp

@bp.route('/', methods=['GET'])
def manufacturing_home():
    return render_template('manufacturing.html')
