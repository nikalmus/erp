from flask import Blueprint, render_template

bp = Blueprint('inventory', __name__, url_prefix='/inventory/', template_folder='templates')

from app.inventory.inventory_item import routes
from app.inventory.stock_move import routes

@bp.route('/', methods=['GET'])
def inventory_home():
    return render_template('inventory.html')