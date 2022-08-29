# Re-run with slurm


export EXPERIMENT_DIR=$HOME/scratch/aug-3-jquery-revdeps/
export Z3_LOC=/mnt/data/pacsolve/z3/build/z3
export Z3_MODEL_OPTION=True
export TARBALL_DIR=/mnt/data/pacsolve/slurm/tarballs_jquery_revdeps_aug3

mkdir -p $EXPERIMENT_DIR
./main.py run --cpus-per-task 1 --use-slurm False --tarball-dir $TARBALL_DIR --z3-abs-path $Z3_LOC --z3-add-model-option $Z3_MODEL_OPTION --target $EXPERIMENT_DIR

