#!/bin/bash
redis-server --loadmodule /home/modules/redisai.so --loadmodule /home/modules/redisgears.so Plugin /home/modules/vector_similarity.so &
python /home/code/similar-images/server.py
