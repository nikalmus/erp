from flask import Blueprint

# Create the blueprint for the manufacturing module
bp = Blueprint('manufacturing', __name__, url_prefix='/manufacturing')

# Import the routes for the manufacturing module
from app.manufacturing.product import routes
from app.manufacturing.bom import routes
from app.manufacturing.mo import routes