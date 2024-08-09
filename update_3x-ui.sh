#!/bin/bash

# wget -O update_3x-ui.sh 

cd ~/3x-ui
docker compose down
docker compose pull 3x-ui
docker compose up -d
