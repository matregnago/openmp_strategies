build:
    g++ -fopenmp mandelbrot.cpp -o mandelbrot
    g++ -fopenmp stencil2d.cpp -o stencil2d

mandelbrot:
    g++ -fopenmp mandelbrot.cpp -o mandelbrot

stencil:
    g++ -fopenmp stencil2d.cpp -o stencil2d

latex-build:
    cd tex && latexmk -pdf relatorio.tex

latex-watch:
    cd tex && latexmk -pdf -pvc relatorio.tex

clean:
    rm -f mandelbrot stencil2d
    cd tex && latexmk -C
