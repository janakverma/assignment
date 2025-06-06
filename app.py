from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello_world():
    """Serves the main Hello World page."""
    return '<h1>Hello, World!</h1><p>Welcome to this basic web application.</p>'

@app.route('/healthz')
def health_check():
    """Provides a health check endpoint."""
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)