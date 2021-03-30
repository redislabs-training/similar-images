#!/bin/bash
## Redis
echo "Starting Redis ..."
redis-server --loadmodule /home/modules/redisai.so --loadmodule /home/modules/redisgears.so Plugin /home/modules/vector_similarity.so &
sleep 5

## Flask
echo "Starting Server ..."
source ./env/bin/activate
export FLASK_APP=server.py
flask run