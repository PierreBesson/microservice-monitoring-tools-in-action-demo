#!/bin/bash

# generate jhipster microservices and gateways
jhipster import-jdl jdl/jhipster-microservice-monitoring-architecture.png

# build docker images
cd store && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
cd invoice && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
cd notification && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
