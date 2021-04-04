#!/bin/bash

# Validate input parameter
if [ -z "$1" ]
  then
    echo "Please specific build environment"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "$1 does not exist"
    exit 1
fi

# Start script
echo "BUILDING DOCKER image for $1"
ROOT=`pwd`
source $1

# React frontend
if [ -n "$REACT_PATH" ]
then
    echo "Building React web frontend......."
    cd $REACT_PATH
    mv .env .env_tmp
    if [ ! -z "${REACT_APP_BASE_URL}" ]
    then
        echo "REACT_APP_BASE_URL=${REACT_APP_BASE_URL}" > .env
    fi
    rm -rf build
    npm run build
    rm .env
    mv .env_tmp .env
    cp -r $REACT_PATH/build/static/* $REACT_PATH/build/
    rm -rf $REACT_PATH/build/static
    mkdir -p $DJANGO_PATH/staticfiles
    rm -rf $DJANGO_PATH/staticfiles/*
    cp -r $REACT_PATH/build/* $DJANGO_PATH/staticfiles/
fi

# Django backend, temporary copy Django project into docker folder.
echo "Copying Django web backend......."
cd ${ROOT}
cp -r $DJANGO_PATH ./tmp_django_app

# Remove un-used files
rm ./tmp_django_app/.env


#echo "Building Docker image............."
docker build -t ${DOCKER_REGISTRY} --build-arg DJANGO_REQUIREMENTS=${DJANGO_REQUIREMENTS} .
docker push ${DOCKER_REGISTRY}

# Clear Temp Django project
rm -rf ./tmp_django_app
