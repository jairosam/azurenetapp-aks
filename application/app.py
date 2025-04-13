from flask import Flask, request, render_template
import os

app = Flask(__name__)
UPLOAD_FOLDER = '/files/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/')
def index():
    return '''
        <h1>Cargar Archivo</h1>
        <form method="POST" action="/upload" enctype="multipart/form-data">
            <input type="file" name="file">
            <button type="submit">Subir</button>
        </form>
    '''

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No se seleccionó ningún archivo'
    file = request.files['file']
    if file.filename == '':
        return 'Nombre del archivo vacío'
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], file.filename))
    return f'Archivo {file.filename} subido exitosamente al directorio {UPLOAD_FOLDER}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
