#!/bin/bash

# generate jhipster microservices and gateways
jhipster import-jdl jdl/microservice-architecture.jdl

# build docker images
cd store && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
cd crm && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
cd accountancy && mvn package -Pprod,zipkin jib:dockerBuild && cd ..
