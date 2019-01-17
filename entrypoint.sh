#!/bin/bash

mkdir -p /rvn-node/data/mongodb/db

rm -f /rvn-node/data/ravend.pid /rvn-node/data/.lock

mongod --fork --logpath /rvn-node/data/mongodb/mongodb.log --setParameter logLevel=0 --dbpath /rvn-node/data/mongodb/db \
  && ravencore-node start
