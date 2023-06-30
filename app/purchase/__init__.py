from flask import Blueprint

bp = Blueprint('purchase', __name__, url_prefix='/purchase/')

from app.purchase.po import routes
from app.purchase.supplier import routes


