from flask import Flask, Blueprint, render_template

from app.manufacturing import bp as manufacturing_bp
from app.inventory import bp as inventory_bp
from app.purchase import bp as purchase_bp
from app.xtras import bp as xtras_bp

from app.manufacturing.product.routes import bp as product_bp
from app.manufacturing.bom.routes import bp as bom_bp
from app.manufacturing.mo.routes import bp as mo_bp

from app.purchase.po.routes import bp as po_bp
from app.purchase.supplier.routes import bp as supplier_bp

from app.inventory.inventory_item.routes import bp as inventory_item_bp
from app.inventory.stock_move.routes import bp as stock_move_bp

from app.xtras.csv.routes import bp as csv_bp

from app.db import connect

home_bp = Blueprint('app', __name__, template_folder='templates')

@home_bp.route('/', methods=['GET'])
def home():
    return render_template('home.html')

def create_app():
    app = Flask(__name__)
    app.secret_key = 'my_secret_key_here'
    app.register_blueprint(home_bp)
    app.register_blueprint(manufacturing_bp)
    app.register_blueprint(inventory_bp)
    app.register_blueprint(purchase_bp)
    app.register_blueprint(xtras_bp)
    app.register_blueprint(product_bp, db_conn = connect)
    app.register_blueprint(bom_bp, db_conn = connect)
    app.register_blueprint(mo_bp, db_conn = connect)
    app.register_blueprint(po_bp, db_conn = connect)
    app.register_blueprint(supplier_bp, db_conn = connect)
    app.register_blueprint(csv_bp)
    app.register_blueprint(inventory_item_bp, db_conn = connect)
    app.register_blueprint(stock_move_bp, db_conn = connect)

    return app
