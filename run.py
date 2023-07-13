import os
from app.__init__ import app

debug = False
if os.environ['DEBUG']:
    debug = True
if __name__ == '__main__':
    app.run(debug=debug)