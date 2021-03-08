import 'dart:async';
import 'dart:html';
//https://progur.com/2017/02/create-mandelbrot-fractal-javascript.html
class Fractal {
    int height = 500;
    int width = 500;
    double panX = 2;
    double panY = 1.5;
    CanvasElement canvas = new CanvasElement(width: 500, height: 500);
    int  magnificationFactor = 200;
    Element parent;
    int maxIterations = 10;
    void attach(Element parent) {
        this.parent = parent;
        parent.append(canvas);
        render();
    }

    void debug() {
        canvas.context2D.fillRect(0,0,500,500);
    }

    double checkIfBelongsToMandelbrotSet(double x, double y) {
        var realComponentOfResult = x;
        var imaginaryComponentOfResult = y;
        for(var i = 0; i < maxIterations; i++) {
            var tempRealComponent = realComponentOfResult * realComponentOfResult
                - imaginaryComponentOfResult * imaginaryComponentOfResult
                + x;
            var tempImaginaryComponent = 2 * realComponentOfResult * imaginaryComponentOfResult
                + y;
            realComponentOfResult = tempRealComponent;
            imaginaryComponentOfResult = tempImaginaryComponent;

            // Return a number as a percentage
            if(realComponentOfResult * imaginaryComponentOfResult > 5)
                return (i/maxIterations * 100);
        }
        return 0;   // Return zero if in set
    }

    void render() {
        CanvasRenderingContext2D ctx = canvas.context2D;
        for(int x=0; x < canvas.width; x++) {
            for(int y=0; y < canvas.height; y++) {
                double belongsToSet =
                checkIfBelongsToMandelbrotSet(x/magnificationFactor - panX,
                    y/magnificationFactor - panY);

                if(belongsToSet == 0) {
                    ctx.fillStyle = '#000';
                    ctx.fillRect(x,y, 1,1); // Draw a black pixel
                } else {
                    ctx.fillStyle = 'hsl(0, 100%, $belongsToSet%)';
                    ctx.fillRect(x,y, 1,1); // Draw a colorful pixel
                }
            }
        }
        maxIterations += 10;
        if(maxIterations > 100) maxIterations = 10;
        new Timer(new Duration(milliseconds: 60), () => render());
    }
}