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

function _install_requirements() {
  _checkpoint "Installing Python requirements..."
  pip install --requirement requirements.txt > /dev/null
  echo
}

function _convert_main() {
  _checkpoint "Converting main..."
  jupyter nbconvert --to python /storage/match_2p0/main.ipynb
  cp /storage/match_2p0/main.py .
}

function _run_main() {
  _checkpoint "Running main.py..."
  python3.7 main.py
}

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
case $1 in
  worker)
    _info "MULTI-NODE: WORKER"
    ;;
  parameter-server)
    _info "MULTI-NODE: PARAMETER SERVER"
    ;;
  job|"")
    _info "SINGLE-NODE: JOB"
    _install_requirements
    _convert_main
    _run_main
    ;;
  hyperparameter)
    _info "HYPERPARAMETER"
    ;;
  *)
    echo "fatal: Invalid run type supplied."
    exit 1
    ;;
esac

