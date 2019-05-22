#!/bin/bash

whoami
pwd

echo "Installing requirements..."
pip install --upgrade --requirement requirements.txt > /dev/null
echo

echo "Starting..."

ipython nbconvert --to python /storage/match_2p0/main.ipynb
mv /storage/match_2p0/main.py /paperspace

python main.py
