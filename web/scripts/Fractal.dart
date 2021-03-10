import 'dart:async';
import 'dart:html';
import 'package:complex/complex.dart';
//https://progur.com/2017/02/create-mandelbrot-fractal-javascript.html <--shamlessly copied this
//https://github.com/HackerPoet/FractalSoundExplorer/blob/main/Main.cpp  <-- inspired by this
class Fractal {
    int height = 500;
    int width = 500;
    double panX = 1.25;
    double panY = 1.25;
    CanvasElement canvas = new CanvasElement(width: 500, height: 500);
    int  magnificationFactor = 200;
    Element parent;
    int maxIterations = 100;
    dynamic fractalChosen;
    StreamSubscription<MouseEvent> listener;
    void attach(Element parent) {
        fractalChosen = sfx;
        if(listener != null) {
            listener.cancel();
        }
        listener = canvas.onClick.listen(drawOrbit);
        this.parent = parent;
        parent.append(canvas);
        render(0);
    }

    double xPtToScreen(double x) {
        return magnificationFactor * x;
    }

    double yPtToScreen(double y) {
        return magnificationFactor * y;
    }

    void drawOrbit(MouseEvent event) {
        //List<Result> orbits = getOrbit(event.page.x-canvas.offset.left, event.page.y-canvas.offset.top,fractalChosen);
       // window.alert("click $orbits");
    }

    void debug() {
        canvas.context2D.fillRect(0,0,500,500);
    }

    //no side effects bro
    Result mandelbrot(double x, double y, Result res) {
        double tempRealComponent = res.realComponentOfResult * res.realComponentOfResult
            - res.imaginaryComponentOfResult * res.imaginaryComponentOfResult
            + x;
        double tempImaginaryComponent = 2 * res.realComponentOfResult * res.imaginaryComponentOfResult
            + y;

        return new Result(tempRealComponent, tempImaginaryComponent);
    }

    /*
    void sfx(double& x, double& y, double cx, double cy) {
  std::complex<double> z(x, y);
  std::complex<double> c2(cx*cx, cy*cy);
  z = z * (x*x + y*y) - (z * c2);
  x = z.real();
  y = z.imag();
}
     */

    Result sfx(double x, double y, Result res) {
        Complex z = new Complex(x,y);
        Complex c2 = new Complex( res.realComponentOfResult*res.realComponentOfResult, res.imaginaryComponentOfResult * res.imaginaryComponentOfResult);
        Complex tmp = z*(x*x + y*y) - (z * c2);
        double tempRealComponent = tmp.real;
        double tempImaginaryComponent = tmp.imaginary;

        return new Result(tempRealComponent, tempImaginaryComponent);
    }

    Result burning_ship(double x, double y, Result res) {
        double tempRealComponent = res.realComponentOfResult * res.realComponentOfResult
            - res.imaginaryComponentOfResult * res.imaginaryComponentOfResult
            + x;
        double tempImaginaryComponent = 2 * (res.realComponentOfResult * res.imaginaryComponentOfResult).abs()
            + y;

        return new Result(tempRealComponent, tempImaginaryComponent);
    }

    List<Result> getOrbit(double x, double y, dynamic equation) {
        List<Result> orbit = new List<Result>();
        Result ongoingResult = new Result(x,y);
        for(var i = 0; i < maxIterations; i++) {
            ongoingResult = equation(x,y,ongoingResult);
            orbit.add(ongoingResult);
            // Return a number as a percentage
            if(ongoingResult.realComponentOfResult * ongoingResult.imaginaryComponentOfResult > 5)
                return orbit;
        }
        return orbit;
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
                    y/magnificationFactor - panY, fractalChosen);

                if(belongsToSet == 0) {
                    ctx.fillStyle = '#000';
                    ctx.fillRect(x,y, 1,1); // Draw a black pixel
                } else {
                    ctx.fillStyle = 'hsl(0, 100%, $belongsToSet%)';
                    ctx.fillRect(x,y, 1,1); // Draw a colorful pixel
                }
            }
        }
    }
}


class Result {
    double realComponentOfResult;
    double imaginaryComponentOfResult;
    Result(double this.realComponentOfResult, double this.imaginaryComponentOfResult);
    @override
    String toString() => "($realComponentOfResult, $imaginaryComponentOfResult)";
}