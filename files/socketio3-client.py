import socketio

sio = socketio.Client()

@sio.event
def connect():
    print('connection established')

@sio.on('my response')
def my_message(data):
    print('message received with ', data)
    sio.emit('my event', {'client event': 'client response'})

@sio.event
def disconnect():
    print('disconnected from server')

sio.connect('http://localhost:5000')
sio.wait()