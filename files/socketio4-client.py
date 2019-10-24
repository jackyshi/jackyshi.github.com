import asyncio
import time
import socketio
import websockets

loop = asyncio.get_event_loop()
sio = socketio.AsyncClient()
start_timer = None


async def send_ping():
    global start_timer
    start_timer = time.time()
    await sio.emit('my event', {'client event': 'client response'})

@sio.event
async def connect():
    print('connected to server')
    await send_ping()

@sio.on('my response')
async def my_message(data):
    print('message received with ', data)
    await hello(str(data))

async def start_server():
    await sio.connect('http://localhost:5000')
    await sio.wait()

async def hello(name):
    uri = "ws://localhost:8765"
    async with websockets.connect(uri) as websocket:
        await websocket.send(name)
        print(f"> {name}")

        greeting = await websocket.recv()
        print(f"< {greeting}")

if __name__ == '__main__':
    loop.run_until_complete(start_server())