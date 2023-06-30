from flask import Flask
from app.manufacturing.product.routes import bp as product_bp
from app.manufacturing.bom.routes import bp as bom_bp
from app.manufacturing.mo.routes import bp as mo_bp
from app.purchase.po.routes import bp as po_bp
from app.purchase.supplier.routes import bp as supplier_bp
from app.db import connect

def create_app():
    app = Flask(__name__)
    app.register_blueprint(product_bp, db_conn = connect)
    app.register_blueprint(bom_bp, db_conn = connect)
    app.register_blueprint(mo_bp, db_conn = connect)
    app.register_blueprint(po_bp, db_conn = connect)
    app.register_blueprint(supplier_bp, db_conn = connect)
    return app
