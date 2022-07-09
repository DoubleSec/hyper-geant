#!/bin/sh

echo "Starting nginx"
sudo nginx
echo "Starting Hyper Geant"
cd /home/ec2-user/hyper-geant
gunicorn -b 127.0.0.1:4000 flaskr:app
