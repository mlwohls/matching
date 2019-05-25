#!/bin/bash

# ------------------------------------------------
# UTILITY ----------------------------------------
# ------------------------------------------------
function _info() {
    echo $1
    echo "--------------------------------------------------"
    env
    echo "--------------------------------------------------"
    echo
    echo
}

function _checkpoint() {
  echo "----> $1"
}

function _run_main() {
  _checkpoint "Installing Python requirements..."
  pip install --requirement requirements.txt > /dev/null
  echo

  _checkpoint "Converting main..."
  jupyter nbconvert --to python /storage/match_2p0/main.ipynb
  cp /storage/match_2p0/main.py .
  echo

  _checkpoint "Running main.py..."
  python3.7 main.py
}

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
case $1 in
  "job")
    _info $1
    _run_main
    ;;
  "experiment:multinode:worker")
    _info $1
    #_run_main
    ;;
  "experiment:multinode:parameterServer")
    _info $1
    ;;
  "experiment:singlenode")
    _info $1
    #_run_main
    ;;
  "hyperparameter:worker")
    _info $1
    #_run_main
    ;;
  *)
    echo "fatal: Invalid run type supplied."
    exit 1
    ;;
esac

