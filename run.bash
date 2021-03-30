#!/bin/bash
## Redis
redis-server --loadmodule /home/modules/redisai.so --loadmodule /home/modules/redisgears.so Plugin /home/modules/vector_similarity.so &

## Flask
source ./env/bin/activate
export FLASK_APP=server.py
flask run