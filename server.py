from flask import Flask, request, send_from_directory
import json
import requests
import cv2
import numpy
from redisearch import Client, Query 
import struct
import base64

INDEX_NAME = 'items'
KEY_PREFIX = 'item:'
VECTOR_PREFIX = 'vector:'
MODEL_KEY = 'efficient'
MODEL_INPUT = 'x'
MODEL_OUTPUT = 'Identity'
IMAGE_WIDTH = 224
IMAGE_HEIGHT = 224

client = Client(INDEX_NAME)

# Create the Search index
try:
    client.info()
except:
    # TODO replace with `client.create_index(SCHEMA, definition=definition)`
    client.redis.execute_command('FT.CREATE', INDEX_NAME, 'ON', 'HASH', 'PREFIX', 1, KEY_PREFIX, 'SCHEMA', 'sku', 'TEXT', 'imageUrl', 'TEXT', 'vector', 'VECTOR', 'FLOAT32', '1280', 'L2', 'HNSW')

# Load the AI model
try:
    client.redis.execute_command('AI.INFO', MODEL_KEY)
except: 
    client.redis.execute_command('AI.MODELSET', MODEL_KEY, 'TF', 'CPU', 'INPUTS', MODEL_INPUT,
                                 'OUTPUTS', MODEL_OUTPUT, 'BLOB', open('EfficientNetB0.pb', 'rb').read())


app = Flask(__name__)

@app.route('/items', methods=['POST'])
def create_item():
    vector = image_url_to_vector(request.json['imageUrl'])
    key = KEY_PREFIX + request.json['sku']

    if client.redis.exists(key):
        return f'{request.json["sku"]} already exists', 400

    client.redis.execute_command('HSET', key, 'sku', request.json['sku'], 'imageUrl', request.json['imageUrl'], 'vector', vector)

    return ''

@app.route('/similar-skus', methods=['GET'])
def get_similar_skus():
    return json.dumps({
        'similarSkus': get_request_similar_skus()
    })


@app.route('/similar-items', methods=['GET'])
def get_similar_items():
    items = get_request_similar_skus()
    return json.dumps({
        'similarItems': items
    })


@app.route('/', defaults={'path': 'index.html'})
@app.route('/<path:path>')
def static_file(path):
    return send_from_directory('./public/dist', path)


def image_url_to_vector(image_url):
    image_bytes = bytearray(requests.get(image_url, stream=True).raw.read())
    image = cv2.imdecode(numpy.asarray(image_bytes, dtype='uint8'), cv2.IMREAD_COLOR)
    resized = (cv2.resize(image, (IMAGE_WIDTH, IMAGE_HEIGHT)) / 128) - 1
    resized_bytes = numpy.asarray(resized, dtype=numpy.float32).tobytes()

    raw = client.redis.execute_command(
        'AI.DAGRUN', '|>',
        'AI.TENSORSET', MODEL_INPUT, 'FLOAT', '1', IMAGE_WIDTH, IMAGE_HEIGHT, '3', 'BLOB', resized_bytes, '|>',
        'AI.MODELRUN', MODEL_KEY, 'INPUTS', MODEL_INPUT, 'OUTPUTS', MODEL_OUTPUT, '|>',
        'AI.TENSORGET', MODEL_OUTPUT, 'VALUES'
    )[2]

    return b''.join([struct.pack('f', float(a)) for a in raw])


def get_request_similar_skus():
    vector = image_url_to_vector(request.args['imageUrl'])
    
    # vector to base to BASE64 
    base64_vector = base64.b64encode(vector).decode('ascii')
    base64_vector_escaped = base64_vector.translate(str.maketrans({"=":  r"\=",
                                          "/":  r"\/",
                                          "+":  r"\+"}))

    q = Query('@vector:[' + base64_vector_escaped + ' range 5]').return_fields('sku', 'imageUrl')
    result = []
    for doc in client.search(q).docs:
        result.append({
            'sku': doc.sku,
            'imageUrl': doc.imageUrl
        })

    return result