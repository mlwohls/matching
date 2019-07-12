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

  if [[ -z $NAME ]] ; then
    echo "fatal: NAME not set."
    exit 1
  fi

  _base_dir="/storage/match_2p0"
  _config_dir="$_base_dir/configs"
  _job_dir="$_base_dir/jobs/$NAME"
  _main_filename="$1"

  _checkpoint "Creating $_job_dir..."
  # ----------------------------------------------
  mkdir $_job_dir

  if [[ ! -d $_job_dir ]] ; then
    echo "fatal: Could not make $_job_dir"
    exit 1
  fi

  _checkpoint "Copying files to $_job_dir..."
  # ----------------------------------------------
  cp -v \
    $_base_dir/*.ipynb \
    $_base_dir/requirements.txt \
    $_job_dir

  cp -v \
    $_config_dir/run_params_$NAME.msgpack \
    $_job_dir/run_params.msgpack

  echo

  _checkpoint "Changing to $_job_dir..."
  # ----------------------------------------------
  cd $_job_dir || exit 1
  echo

  _checkpoint "Making job-specific subdirectories..."
  # ----------------------------------------------
  mkdir -p models/logs
  echo

  _checkpoint "Installing Python requirements..."
  # ----------------------------------------------
  pip install --upgrade --requirement requirements.txt > /dev/null
  echo

  _checkpoint "Converting $_main_filename.ipynb..."
  # ----------------------------------------------
  jupyter nbconvert --to python $_main_filename.ipynb
  echo

  _checkpoint "Running $_main_filename.py..."
  # ----------------------------------------------
  python3.7 $_main_filename.py
}

# ------------------------------------------------
# MAIN -------------------------------------------
# ------------------------------------------------
case $1 in
  "job")
    _info $1
    _run_main "main_job"
    ;;
  "retrain")
    _info $1
    _run_main "retrain_job"
    ;;
  *)
    echo "fatal: Invalid run type supplied."
    exit 1
    ;;
esac

