# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/measure', methods=['POST'])
def measure():
    data = request.get_json()
    image_path = data.get("image_path")
    height = data.get("height")

    if not image_path or not height:
        return jsonify({"error": "Missing 'image_path' or 'height'"}), 400

    try:
        # Nota: O Dockerfile garante que este comando é executado no diretório correto.
        result = subprocess.run(
            ["python", "inference.py", "-i", image_path, "-ht", str(height)],
            capture_output=True,
            text=True,
            check=True
        )
        return jsonify({"output": result.stdout})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": e.stderr}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)