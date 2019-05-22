#!/bin/bash

echo "Sesion:"
whoami
pwd
echo

which python
python --version
ls -1 /usr/bin | grep python
ls -1 /usr/local/bin | grep python

test -d /notebooks && ls -1 /notebooks
echo
echo
ls -1 /root/.fastai
echo
echo
test -d /root/.fastai && ls -1 /root/.fastai

echo "Installing requirements..."
pip install --requirement requirements.txt > /dev/null
echo

echo "Converting..."
jupyter nbconvert --to python /storage/match_2p0/main.ipynb
cp /storage/match_2p0/main.py .

echo "Starting..."
python main.py
