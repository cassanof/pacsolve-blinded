export EXPERIMENT_DIR=/scratch/jul-25-cve/
export Z3_LOC=/work/pacsolve/z3/build/z3
export Z3_MODEL_OPTION=True
export TARBALL_DIR=/work/pacsolve/slurm/top1000tarballs

mkdir -p $EXPERIMENT_DIR
./main.py run --tarball-dir $TARBALL_DIR --z3-abs-path $Z3_LOC --z3-add-model-option $Z3_MODEL_OPTION --target $EXPERIMENT_DIR
