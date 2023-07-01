from flask import Blueprint

bp = Blueprint('inventory', __name__, url_prefix='/inventory/')

from app.inventory.inventory_item import routes
from app.inventory.stock_move import routes