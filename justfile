build:
    g++ -O3 -fopenmp mandelbrot.cpp -o mandelbrot
    g++ -O3 -fopenmp stencil2d.cpp -o stencil2d

mandelbrot:
    g++ -O3 -fopenmp mandelbrot.cpp -o mandelbrot

stencil:
    g++ -O3 -fopenmp stencil2d.cpp -o stencil2d

latex-build:
    cd tex && latexmk -pdf relatorio.tex

latex-watch:
    cd tex && latexmk -pdf -pvc relatorio.tex

sync-pcad:
    rsync --verbose --progress --recursive --links --times \
    --exclude='.git/' \
    --exclude='results/' \
    --exclude='*.out' \
    --exclude='tex/' \
    --exclude='pcad/' \
    ./ "pcad:~/openmp/"

get-pcad:
    rsync --verbose --progress --recursive --links --times "pcad:~/openmp/" ./

clean:
    rm -f mandelbrot stencil2d
    cd tex && latexmk -C
