# Based on Redis
FROM redis:6.2.1

# Prepare some folders
RUN mkdir /home/code
RUN mkdir /home/modules

# Install some packages
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y make
RUN apt-get install -y python3
RUN apt-get install -y wget
RUN apt-get install -y unzip

# Build RedisAI
RUN cd /home/code/
WORKDIR /home/code/
## Get the sourc code
RUN git clone https://github.com/RedisAI/RedisAI.git
RUN cd /home/code/RedisAI
WORKDIR /home/code/RedisAI
## Get the referenced source code
RUN ./get_deps.sh cpu
RUN cd /home/code/RedisAI/opt
WORKDIR /home/code/RedisAI/opt
## Install system requirements
RUN ./readies/bin/getpy3
RUN ./system-setup.py
## Build Redis AI
RUN cd /home/code/RedisAI
WORKDIR /home/code/RedisAI
RUN ALL=1 make -C opt clean build
RUN cp ./bin/linux-x64-release/src/redisai.so /home/modules/redisai.so

# Build RedisGears
RUN cd /home/code/
WORKDIR /home/code/
RUN git clone https://github.com/RedisGears/RedisGears.git
RUN cd /home/code/RedisGears
WORKDIR /home/code/RedisGears
RUN git submodule update --init --recursive
RUN ./deps/readies/bin/getpy2
RUN make setup
RUN make fetch
RUN make all
RUN cp ./bin/linux-x64-release/redisgears.so /home/modules/redisgears.so

# Build VecSim
## TODO

# Run Redis
CMD redis-server --loadmodule /home/modules/redisai.so --loadmodule /home/modules/redisgears.so
