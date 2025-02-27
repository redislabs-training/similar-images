# Based on Redis
FROM redis:6.2.1

# Constants
ENV BUILD_HOME=/opt

# Prepare some folders
RUN mkdir $BUILD_HOME/code
RUN mkdir $BUILD_HOME/modules
RUN mkdir $BUILD_HOME/creds

# Install some packages
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y make
RUN apt-get install -y python3
RUN apt-get install -y wget
RUN apt-get install -y unzip
RUN apt-get install -y python3-opencv

# Build RedisAI
RUN cd $BUILD_HOME/code/
WORKDIR $BUILD_HOME/code/
## Get the sourc code
RUN git clone https://github.com/RedisAI/RedisAI.git --recurse-submodules
RUN cd $BUILD_HOME/code/RedisAI
WORKDIR $BUILD_HOME/code/RedisAI
## Get the referenced source code
RUN ./get_deps.sh cpu
RUN cd $BUILD_HOME/code/RedisAI/opt
WORKDIR $BUILD_HOME/code/RedisAI/opt
## Install system requirements
RUN ./readies/bin/getpy3
RUN ./system-setup.py
## Build Redis AI
RUN cd $BUILD_HOME/code/RedisAI
WORKDIR $BUILD_HOME/code/RedisAI
RUN ALL=1 make -C opt clean build
RUN cp ./bin/linux-x64-release/src/redisai.so $BUILD_HOME/modules/redisai.so
RUN cp ./bin/linux-x64-release/src/redisai_tensorflow.so $BUILD_HOME/modules/redisai_tensorflow.so

## RediSearch ##
WORKDIR $BUILD_HOME/code/
RUN git clone https://github.com/RediSearch/RediSearch.git --recurse-submodules
WORKDIR $BUILD_HOME/code/RediSearch
RUN git checkout feature-vecsim
WORKDIR $BUILD_HOME/code/RediSearch/deps
RUN git submodule add -f https://github.com/RedisLabsModules/VectorSimilarity.git
RUN git submodule update --init --recursive
WORKDIR $BUILD_HOME/code/RediSearch
RUN ./deps/readies/bin/getpy2
RUN make setup
RUN make build 
RUN cp build/redisearch.so $BUILD_HOME/modules/.

# Build the service
RUN echo "Installing service dependencies ..."
RUN cd $BUILD_HOME/code/
WORKDIR $BUILD_HOME/code/
RUN git clone https://github.com/redislabs-training/similar-images.git
RUN cd $BUILD_HOME/code/similar-images
WORKDIR $BUILD_HOME/code/similar-images
RUN pip3 install virtualenv
RUN virtualenv env
RUN  /bin/bash -c "source ./env/bin/activate;pip install -r requirments.txt"
RUN chmod +x run.bash

# Ports
EXPOSE 5000
EXPOSE 6379

# Run Redis
CMD $BUILD_HOME/code/similar-images/run.bash
