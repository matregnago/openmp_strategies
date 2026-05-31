#include <iostream>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <omp.h>

const int N = 8192;
const int ITERATIONS = 100;

int main() {
    bool first_touch = true;
    if (const char* env = std::getenv("FIRST_TOUCH")) {
        if (std::strcmp(env, "0") == 0) first_touch = false;
    }

    double start_time = omp_get_wtime();

    double* grid     = new double[N * N];
    double* new_grid = new double[N * N];

    if (first_touch) {
        #pragma omp parallel for schedule(static)
        for (int i = 0; i < N * N; ++i) {
            grid[i]     = 1.0;
            new_grid[i] = 1.0;
        }
    } else {
        for (int i = 0; i < N * N; ++i) {
            grid[i]     = 1.0;
            new_grid[i] = 1.0;
        }
    }

    for (int iter = 0; iter < ITERATIONS; ++iter) {
        #pragma omp parallel for schedule(runtime)
        for (int i = 1; i < N - 1; ++i) {
            for (int j = 1; j < N - 1; ++j) {
                new_grid[i * N + j] = 0.25 * (
                    grid[(i - 1) * N + j] +
                    grid[(i + 1) * N + j] +
                    grid[i * N + (j - 1)] +
                    grid[i * N + (j + 1)]
                );
            }
        }
        std::swap(grid, new_grid);
    }

    double end_time = omp_get_wtime();
    std::cout << (end_time - start_time) << std::endl;

    delete[] grid;
    delete[] new_grid;
    return 0;
}
