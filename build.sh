#!/bin/bash

docker stop laravel > /dev/null 2>&1
docker build -t laravel-ubi8 .
docker run --rm -itd -p 8080:8080 --name laravel laravel-ubi8
docker exec -it laravel bash