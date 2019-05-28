#!/bin/bash

# ------------------------------------------------
# UTILITY ----------------------------------------
# ------------------------------------------------
function _info() {
    echo "Starting: Type: $1"
    echo "--------------------------------------------------"
    env
    echo "--------------------------------------------------"
    echo
    echo
}

function _create_initial_artifacts() {
  echo $1 > $PS_ARTIFACTS/type
  env > $PS_ARTIFACTS/env
}

function _checkpoint() {
  echo "----> $1"
}

function _run_main() {

  _main_filename="main"

  if [[ $1 == "job" ]] ; then
    _main_filename="main_job"
  fi

  _checkpoint "Installing Python requirements..."
  pip install --upgrade --requirement requirements.txt > /dev/null
  echo

  _checkpoint "Converting main..."
  jupyter nbconvert --to python /storage/match_2p0/$_main_filename.ipynb
  cp /storage/match_2p0/$_main_filename.py .
  echo

  _checkpoint "Running $_main_filename.py..."
  python3.7 $_main_filename.py
}

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
case $1 in
  "job")
    _info $1
    _run_main $1
    ;;
  "experiment:multinode:worker")
    _info $1
    _run_main $1
    ;;
  "experiment:multinode:parameterServer")
    _info $1
    # FIX:
    ;;
  "experiment:singlenode")
    _info $1
    _run_main $1
    ;;
  "hyperparameter:worker")
    _info $1
    _run_main $1
    ;;
  "hyperparameter:tune")
    _info $1
    # FIX:
    python3.7 hyperparameter_tune.py
    ;;
  *)
    echo "fatal: Invalid run type supplied."
    exit 1
    ;;
esac

