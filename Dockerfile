FROM ubuntu:trusty

RUN apt-get update && apt-get install -y \
  g++ \
  libzmq3-dev \
  libzmq3-dbg \
  libzmq3 \
  make \
  python \
  software-properties-common \
  curl \
  build-essential \
  libssl-dev \
  wget

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN apt-get install -y \
  libtool \
  autotools-dev \
  automake \
  pkg-config \
  libssl-dev \
  libevent-dev \
  bsdmainutils \
  git

RUN add-apt-repository ppa:bitcoin/bitcoin -y
RUN apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

RUN apt-get install -y \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-chrono-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libboost-thread-dev

# If you need to rebuild node from source.
# RUN git clone https://github.com/raven-dark/raven-dark.git && \
#  cd raven-dark && \
#  ./autogen.sh && \
#  ./configure --without-gui && make

RUN mkdir /ravendark

RUN wget -qO- https://github.com/raven-dark/bins/raw/master/raven-dark-0.2.0-ubuntu-rc1.tar.gz | tar xvz -C /ravendark

RUN chmod +x /ravendark/ravendarkd
RUN chmod +x /ravendark/ravendark-cli

RUN npm config set package-lock false && npm install raven-dark/ravendark-node

RUN ./node_modules/.bin/dashcore-node create xrd-node && \
  cd xrd-node && \
  ./node_modules/.bin/dashcore-node install raven-dark/ravendark-insight-api && \
  ./node_modules/.bin/dashcore-node install raven-dark/ravendark-insight-ui

RUN apt-get purge -y \
  g++ make python gcc && \
  apt-get autoclean && \
  apt-get autoremove -y

WORKDIR /xrd-node
COPY ravendarkcore-node.json ./dashcore-node.json
COPY ravendark.conf ./data/dash.conf

#PORT 3001 is for insight, 9998 is for rpc, 7208 is p2p
EXPOSE 80 6666 6665

VOLUME /xrd-node/data

ENTRYPOINT ["/node_modules/.bin/dashcore-node", "start"]
