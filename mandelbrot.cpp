#include <iostream>
#include <complex>
#include <vector>
#include <omp.h>

const int WIDTH = 4096;
const int HEIGHT = 4096;
const int MAX_ITER = 1000;

int main() {
    double start_time = omp_get_wtime();
    std::vector<int> image(WIDTH * HEIGHT);


    #pragma omp parallel for schedule(runtime)
    for (int y = 0; y < HEIGHT; ++y) {
        for (int x = 0; x < WIDTH; ++x) {

            double real = (x - WIDTH / 2.0) * 4.0 / WIDTH;
            double imag = (y - HEIGHT / 2.0) * 4.0 / HEIGHT;

            std::complex<double> c(real, imag);
            std::complex<double> z(0, 0);

            int iter = 0;
            while (std::abs(z) <= 2.0 && iter < MAX_ITER) {
                z = z * z + c;
                iter++;
            }

            image[y * WIDTH + x] = iter;
        }
    }

    double end_time = omp_get_wtime();
    std::cout << (end_time - start_time) << std::endl;
    return 0;
}
