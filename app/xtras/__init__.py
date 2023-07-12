from flask import Blueprint, render_template

bp = Blueprint('xtras', __name__, url_prefix='/xtras/', template_folder='templates')

from app.xtras.csv import routes

@bp.route('/', methods=['GET'])
def xtras_home():
    return render_template('xtras.html')