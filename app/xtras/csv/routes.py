from flask import Blueprint, render_template, redirect, url_for

bp = Blueprint('csv', __name__, template_folder='templates')

@bp.route('/xtras/csv')
def get_csv():
    return render_template('csv.html')
