#!/bin/bash

echo "Starting HTTP server ..."
python3 -m http.server &
IMG_SERVER_PID=$!
# Important: This needs to be a host name which is resovlable from within the AI server container
IMG_SERVER_HOST=davids-mbp-16-rl
IMG_SERVER_PORT=8000
sleep 5
echo "img_server_pid = $IMG_SERVER_PID"

echo "Test if the image is recognized ..."
AI_SERVER_HOST=localhost
AI_SERVER_PORT=5000
TEST_IMG="http://$IMG_SERVER_HOST:$IMG_SERVER_PORT/test_marshall.jpg"
echo "test_img = $TEST_IMG"
curl http://$AI_SERVER_HOST:$AI_SERVER_PORT/similar-skus?imageUrl=$TEST_IMG

echo ""
read -p "Press enter to continue"

# Kill the image server
kill $IMG_SERVER_PID
