import time

import dash
import dash_html_components as html
from flask_socketio import SocketIO
from flask_cors import CORS
from flask_cors import cross_origin
from flask_socketio import send, emit


app = dash.Dash(__name__)
server = app.server

server.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(server,cors_allowed_origins="*")

@socketio.on('my event')
def test_message(message):
    emit('my response', {'data': message['data']}, broadcast=True )
    print(message)

@socketio.on('connect')
def test_connect():
    emit('my response', {'data': 'Connected'} )

@socketio.on('disconnect')
def test_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    app.run_server(debug=False,port=5000)