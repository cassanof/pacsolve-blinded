export EXPERIMENT_DIR=/scratch/apr-6-minnpm-exp-new-z3/
export Z3_LOC=/work/pacsolve/z3/build/z3
export Z3_MODEL_OPTION=True

mkdir -p $EXPERIMENT_DIR
./main.py run --tarball-dir /work/minnpm-slurm/tarballs --z3-abs-path $Z3_LOC --z3-add-model-option $Z3_MODEL_OPTION --target $EXPERIMENT_DIR
