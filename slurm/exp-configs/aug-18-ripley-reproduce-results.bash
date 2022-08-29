#!/bin/bash
# This experiment is my attempt to test if experiment scripts work on Ripley


export EXPERIMENT_TYPE=top1000_comparison
export EXPERIMENT_DIR=/proj/experiments/aug-18-ripley-reproduce-results-no-registry/
export TARBALL_DIR=/proj/pacsolve/slurm/top1000tarballs

export Z3_LOC=/proj/pacsolve/z3/build/z3
export Z3_MODEL_OPTION=True

mkdir -p $EXPERIMENT_DIR
./main.py run --cpus-per-task 1 --max-groups -1 --on-ripley --tarball-dir $TARBALL_DIR --z3-abs-path $Z3_LOC --z3-add-model-option $Z3_MODEL_OPTION --target $EXPERIMENT_DIR --which-experiment $EXPERIMENT_TYPE

