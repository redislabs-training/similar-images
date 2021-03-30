# Based on Redis
FROM redis:6.2.1

# Build arguments
ARG GH_TOKEN=null
ARG GH_USER=null

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

# Build RedisAI
RUN cd $BUILD_HOME/code/
WORKDIR $BUILD_HOME/code/
## Get the sourc code
RUN git clone https://github.com/RedisAI/RedisAI.git
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

# Build RedisGears
RUN cd $BUILD_HOME/code/
WORKDIR $BUILD_HOME/code/
RUN git clone https://github.com/RedisGears/RedisGears.git
RUN cd $BUILD_HOME/code/RedisGears
WORKDIR $BUILD_HOME/code/RedisGears
RUN git submodule update --init --recursive
RUN ./deps/readies/bin/getpy2
RUN make setup
RUN make fetch
RUN make all
RUN cp ./bin/linux-x64-release/redisgears.so $BUILD_HOME/modules/redisgears.so

# Build VecSim
## Prepare creds
RUN cd $BUILD_HOME/creds/
WORKDIR $BUILD_HOME/creds/
RUN echo '#!/bin/bash' > github.bash
RUN echo "echo username=${GH_USER}" >> github.bash
RUN echo "echo password=${GH_TOKEN}" >> github.bash
RUN chmod +x github.bash
RUN cd $BUILD_HOME/code/
WORKDIR $BUILD_HOME/code/
RUN git -c credential.helper="$BUILD_HOME/creds/github.bash" clone https://github.com/RedisGears/VecSim.git
RUN rm $BUILD_HOME/creds/github.bash
RUN cd $BUILD_HOME/code/VecSim
WORKDIR $BUILD_HOME/code/VecSim
RUN git submodule update --init --recursive
RUN sed -i 's/#define VEC_SIZE 128/#define VEC_SIZE 1280/g' ./src/vector_similarity.c
RUN sed -i 's/#define VEC_HOLDER_SIZE 1024 * 1024/#define VEC_HOLDER_SIZE 100 * 1024/g' ./src/vector_similarity.c
RUN cd $BUILD_HOME/code/VecSim/deps/OpenBLAS/
WORKDIR $BUILD_HOME/code/VecSim/deps/OpenBLAS/
RUN make
RUN cd $BUILD_HOME/code/VecSim/src/
WORKDIR $BUILD_HOME/code/VecSim/src/
RUN make
RUN cp vector_similarity.so $BUILD_HOME/modules/vector_similarity.so

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
