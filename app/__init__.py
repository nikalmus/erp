from flask import Flask
from app.product.routes import bp as product_bp
from app.bom.routes import bp as bom_bp
from app.db import connect

def create_app():
    app = Flask(__name__)
    app.register_blueprint(product_bp, db_conn = connect)
    app.register_blueprint(bom_bp, db_conn = connect)
    return app
