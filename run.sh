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
  worker)
    _info "MULTI-NODE: WORKER"
    _run_main
    ;;
  parameterServer)
    _info "MULTI-NODE: PARAMETER SERVER"
    ;;
  job|"")
    _info "SINGLE-NODE: JOB"
    _run_main
    ;;
  hyperparameter)
    _info "HYPERPARAMETER: WORKER"
    _run_main
    ;;
  *)
    echo "fatal: Invalid run type supplied."
    exit 1
    ;;
esac

