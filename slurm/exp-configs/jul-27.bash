# This experiment is the second attempt to run vanilla with npm audit fix and npm audit fix --force,
# as well as minnpm min_cve.
# Compared to jul-26, this fixes npm audit to return a status code of 0, and *hopefully* fixes weird timeout reports with vanilla NPM?


export EXPERIMENT_DIR=/scratch/jul-27/
export Z3_LOC=/work/pacsolve/z3/build/z3
export Z3_MODEL_OPTION=True
export TARBALL_DIR=/work/pacsolve/slurm/top1000tarballs

mkdir -p $EXPERIMENT_DIR
./main.py run --tarball-dir $TARBALL_DIR --z3-abs-path $Z3_LOC --z3-add-model-option $Z3_MODEL_OPTION --target $EXPERIMENT_DIR
