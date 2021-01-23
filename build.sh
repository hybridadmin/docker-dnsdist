#!/bin/bash

BUILD_VERSION=$1

if [ -f ${BUILD_VERSION}/Dockerfile ]; then
        echo -e "\e[93m Starting build for version ${BUILD_VERSION}... \e[0m"
        docker build -f ${BUILD_VERSION}/Dockerfile -t hybridadmin/dnsdist:${BUILD_VERSION} .
else
        echo -e "\e[31m No Dockerfile for build version ${BUILD_VERSION} \e[0m"
fi
