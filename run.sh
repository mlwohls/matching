#!/bin/bash

# cd /paperspace
# ls -1
# echo "sample artifact" > /artifacts/test.txt

echo "Installing requirements..."
pip install --upgrade --requirement requirements.txt > /dev/null

echo "Starting main.py..."
python main.py

