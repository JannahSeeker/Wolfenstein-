from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Global state for key presses
key_state = {
    "w": False,
    "a": False,
    "s": False,
    "d": False
}

@app.route("/keypress", methods=["GET"])
def get_keypress():
    return jsonify(key_state)

@app.route("/keypress", methods=["POST"])
def update_keypress():
    data = request.get_json()
    for key in ['w', 'a', 's', 'd']:
        if key in data:
            key_state[key] = bool(data[key])
    print(data)
    print(key_state)
    print(jsonify(key_state))
    print("-----")
    return jsonify({"status": "updated", "key_state": key_state})


if __name__ == "__main__":
    app.run(debug=True, port=5555)