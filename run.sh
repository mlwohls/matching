#!/bin/bash

cd /paperspace

ls -1

echo "sample artifact" > /artifacts/test.txt

pip install -U gradient-statsd

python main.py

