#!/bin/bash
set -euo pipefail

just

RESULTS_DIR="$SCRATCH/openmp_exp/results"
mkdir -p "$RESULTS_DIR"

PHASE1_CSV="$RESULTS_DIR/phase1.csv"
PHASE2_CSV="$RESULTS_DIR/phase2.csv"
PHASE3_CSV="$RESULTS_DIR/phase3.csv"
PHASE4_CSV="$RESULTS_DIR/phase4.csv"


echo "algorithm,omp_num_threads,replication,time" > "$PHASE1_CSV"
echo "algorithm,omp_schedule,chunk,replication,time" > "$PHASE2_CSV"
echo "algorithm,omp_proc_bind,omp_places,replication,time" > "$PHASE3_CSV"
echo "algorithm,first_touch,omp_num_threads,replication,time" > "$PHASE4_CSV"

THREADS_LIST=(1 2 4 8 10 16 20 32 40 64)
SCHEDULE_LIST=(static dynamic guided auto)
CHUNK_LIST=(1 2 4 8 16 32 64)
PROC_BIND_LIST=(TRUE FALSE MASTER CLOSE SPREAD)
PLACES_LIST=(sockets cores threads)
FT_THREADS_LIST=(8 16 20 32 40)

REPS=10

# Fase 1: variando numero de threads
unset OMP_SCHEDULE OMP_PROC_BIND OMP_PLACES
for num_threads in "${THREADS_LIST[@]}"; do
    for rep in $(seq 1 "$REPS"); do
        time=$(OMP_NUM_THREADS="$num_threads" ./mandelbrot)
        echo "mandelbrot,$num_threads,$rep,$time" >> "$PHASE1_CSV"

        time=$(OMP_NUM_THREADS="$num_threads" ./stencil2d)
        echo "stencil2d,$num_threads,$rep,$time"  >> "$PHASE1_CSV"
    done
done

# Fase 2: variando escalonador e tamanho do chunk com numero de threads fixo
num_threads=20
for schedule_base in "${SCHEDULE_LIST[@]}"; do
    for chunk in "${CHUNK_LIST[@]}"; do
        for rep in $(seq 1 "$REPS"); do
            time=$(OMP_NUM_THREADS="$num_threads" OMP_SCHEDULE="${schedule_base},${chunk}" ./mandelbrot)
            echo "mandelbrot,$schedule_base,$chunk,$rep,$time" >> "$PHASE2_CSV"

            time=$(OMP_NUM_THREADS="$num_threads" OMP_SCHEDULE="${schedule_base},${chunk}" ./stencil2d)
            echo "stencil2d,$schedule_base,$chunk,$rep,$time"  >> "$PHASE2_CSV"
        done
    done
done

# Fase 3: variando OMP_PROC_BIND e OMP_PLACES
num_threads=20
unset OMP_SCHEDULE
for proc_bind in "${PROC_BIND_LIST[@]}"; do
    for places in "${PLACES_LIST[@]}"; do
        for rep in $(seq 1 "$REPS"); do
            time=$(OMP_NUM_THREADS="$num_threads" \
                       OMP_PROC_BIND="$proc_bind" OMP_PLACES="$places" \
                       ./mandelbrot)
            echo "mandelbrot,$proc_bind,$places,$rep,$time" >> "$PHASE3_CSV"

            time=$(OMP_NUM_THREADS="$num_threads" \
                       OMP_PROC_BIND="$proc_bind" OMP_PLACES="$places" \
                       ./stencil2d)
            echo "stencil2d,$proc_bind,$places,$rep,$time"  >> "$PHASE3_CSV"
        done
    done
done

# Fase 4 com e sem first-touch no stencil
unset OMP_SCHEDULE
for ft in 1 0; do
    for num_threads in "${FT_THREADS_LIST[@]}"; do
        for rep in $(seq 1 "$REPS"); do
            time=$(OMP_NUM_THREADS="$num_threads" \
                       OMP_PROC_BIND=spread OMP_PLACES=cores \
                       FIRST_TOUCH="$ft" \
                       ./stencil2d)
            echo "stencil2d,$ft,$num_threads,$rep,$time" >> "$PHASE4_CSV"
        done
    done
done

cp -r "$RESULTS_DIR" "$SLURM_SUBMIT_DIR/"
