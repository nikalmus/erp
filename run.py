from app import app,create_app

if __name__ == '__main__':
    app = create_app("production")
    app.run(debug=False)