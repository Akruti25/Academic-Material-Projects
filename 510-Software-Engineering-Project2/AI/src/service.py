from flask import Flask, jsonify
from inference import inference
app = Flask(__name__)
csrf = CSRFProtect()
csrf.init_app(app) # Compliant

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/recipe/<recipe_name>')
def recommend(recipe_name):
    print("predicting",recipe_name)
    return jsonify(inference(recipe_name))

if __name__ == "__main__":
    app.run(port=8000,debug=False) 