from app.__init__ import app
from app import create_app

if __name__ == '__main__':
    app.run(debug=False)