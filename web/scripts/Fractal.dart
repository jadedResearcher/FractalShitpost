import 'dart:async';
import 'dart:html';
//https://progur.com/2017/02/create-mandelbrot-fractal-javascript.html <--shamlessly copied this
//https://github.com/HackerPoet/FractalSoundExplorer/blob/main/Main.cpp  <-- inspired by this
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
        render(0);
    }

    void debug() {
        canvas.context2D.fillRect(0,0,500,500);
    }

    //no side effects bro
    Result mandelbrot(double x, double y, Result res) {
        var tempRealComponent = res.realComponentOfResult * res.realComponentOfResult
            - res.imaginaryComponentOfResult * res.imaginaryComponentOfResult
            + x;
        var tempImaginaryComponent = 2 * res.realComponentOfResult * res.imaginaryComponentOfResult
            + y;

        return new Result(tempRealComponent, tempImaginaryComponent);
    }

    Result burning_ship(double x, double y, Result res) {
        var tempRealComponent = res.realComponentOfResult * res.realComponentOfResult
            - res.imaginaryComponentOfResult * res.imaginaryComponentOfResult
            + x;
        var tempImaginaryComponent = 2 * (res.realComponentOfResult * res.imaginaryComponentOfResult).abs()
            + y;

        return new Result(tempRealComponent, tempImaginaryComponent);
    }

    double checkIfBelongsToSet(double x, double y, dynamic equation) {
        Result ongoingResult = new Result(x,y);
        for(var i = 0; i < maxIterations; i++) {
            ongoingResult = equation(x,y,ongoingResult);
            // Return a number as a percentage
            if(ongoingResult.realComponentOfResult * ongoingResult.imaginaryComponentOfResult > 5)
                return (i/maxIterations * 100);
        }
        return 0;   // Return zero if in set
    }

    void render(num placeholder) {
        CanvasRenderingContext2D ctx = canvas.context2D;
        for(int x=0; x < canvas.width; x++) {
            for(int y=0; y < canvas.height; y++) {
                double belongsToSet =
                checkIfBelongsToSet(x/magnificationFactor - panX,
                    y/magnificationFactor - panY, burning_ship);

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
        new Timer(new Duration(milliseconds: 100), () => window.requestAnimationFrame(render));
    }
}


class Result {
    double realComponentOfResult;
    double imaginaryComponentOfResult;
    Result(double this.realComponentOfResult, double this.imaginaryComponentOfResult);
}