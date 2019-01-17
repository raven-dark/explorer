FROM ubuntu:trusty

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y \
    wget bsdmainutils curl cmake build-essential libtool autotools-dev automake \
    pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-all-dev git \
    libminiupnpc-dev libprotobuf-dev libqrencode-dev python-zmq libzmq3-dev \
    ca-certificates software-properties-common apt-transport-https

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
  echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
  apt-get update && \
  apt-get install -y mongodb-org

RUN add-apt-repository ppa:bitcoin/bitcoin \
  && apt-get update \
  && apt-get install -y \
    libdb4.8-dev \
    libdb4.8++-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
ENV NODE_VERSION 8.12.0
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION"

ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/node /usr/bin/nodejs
RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/node /usr/bin/node
RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/npm /usr/bin/npm

RUN mkdir -p /ravendark

RUN wget -qO- https://github.com/raven-dark/bins/raw/master/raven-dark-0.2.1-ubuntu-rc2.tar.gz | tar xvz -C /ravendark

RUN chmod +x /ravendark/ravendarkd
RUN chmod +x /ravendark/ravendark-cli
RUN echo 2
WORKDIR /
RUN npm config set package-lock false && \
  npm install raven-dark/ravencore-node

RUN ln -sf /node_modules/ravencore-node/bin/ravencore-node /usr/bin/ravencore-node
RUN ravencore-node create rvn-node
RUN echo 2
WORKDIR /rvn-node
RUN  ravencore-node install raven-dark/insight-api \
  && ravencore-node install raven-dark/insight-ui

COPY ravencore-node.json ./ravencore-node.json
COPY ravendark.conf ./conf/ravendark.conf
COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x entrypoint.sh

VOLUME /rvn-node/data

EXPOSE 80 16666

HEALTHCHECK --interval=120s --timeout=120s --retries=5 CMD curl -f http://localhost:80/api/sync

ENTRYPOINT ["./entrypoint.sh"]
