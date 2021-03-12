import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'package:complex/complex.dart';
import 'dart:svg';
//https://progur.com/2017/02/create-mandelbrot-fractal-javascript.html <--shamlessly copied this
//https://github.com/HackerPoet/FractalSoundExplorer/blob/main/Main.cpp  <-- inspired by this
class Fractal {
    int height = 500;
    int width = 500;
    bool autoMode = true;
    double autoX = -0.8;
    double autoY = -0.8;
    double panX = 1.25;
    Random rand = new Random();
    double panY = 1.25;
    AudioContext context = new AudioContext();
    bool mouseDown = false;
    SvgElement svg = new SvgElement.tag("svg");
    CanvasElement canvas = new CanvasElement(width: 500, height: 500);
    int  magnificationFactor = 300;
    Element parent;
    int maxDrawIterations = 10;
    int maxOrbitIterations = 100;
    PathElement path = new PathElement();
    List<dynamic> fractals;
    int fractalChoiceIndex = 0;
    OscillatorNode osc;

    void attach(Element parent) {
        fractals = [burning_ship, mandelbrot, sfx];
        osc = context.createOscillator();
        osc.start2(0);

        canvas.onMouseDown.listen((MouseEvent event) {
            mouseDown = true;
            autoMode = false;
        });
        window.onMouseUp.listen((MouseEvent event) => mouseDown = false);

        canvas.onMouseMove.listen((MouseEvent event) {
            double point_x = event.page.x-canvas.offset.left;
            point_x = point_x/magnificationFactor - panX;
            double point_y = event.page.y-canvas.offset.top;
            point_y = point_y/magnificationFactor -panY;
            mouseDown? drawOrbit(point_x, point_y) : null;
        });
        window.onKeyPress.listen((KeyboardEvent event) {
            print("key press");
            fractalChoiceIndex = (fractalChoiceIndex + 1) % fractals.length;
            render(0);
        });

        this.parent = parent;
        parent.append(canvas);
        parent.append(svg);
        svg.append(path);
        render(0);
        doAutoMode(0);
    }

    void doAutoMode(num frame) {
        if(!autoMode) return;
        double maxNum = 1.0;
        double minNum = -1.0;
        autoX = max(minNum, autoX);
        autoX = min(maxNum, autoX);
        autoY = max(minNum, autoX);
        autoY = min(maxNum, autoX);
        int ratio = 30;
        if(rand.nextDouble() > 0.5) {
            autoX += rand.nextDouble()/ratio;
        }else {
            autoX += -1* rand.nextDouble()/ratio;
        }

        if(rand.nextDouble() > 0.5) {
            autoY += rand.nextDouble()/ratio;
        }else {
            autoY += -1* rand.nextDouble()/ratio;
        }

        drawOrbit(autoX,autoY);
        new Timer(new Duration(milliseconds: 60), () => window.requestAnimationFrame(doAutoMode));
    }

    double xPtToScreen(double x) {
        return magnificationFactor * x;
    }

    double yPtToScreen(double y) {
        return magnificationFactor * y;
    }

    void beep(List<Result> orbits) {
            List<double> reals = orbits.map((Result item) =>
            item.realComponentOfResult).toList();
            List<double> fakes = orbits.map((Result item) =>
            item.imaginaryComponentOfResult).toList();

            var wave = context.createPeriodicWave(reals, fakes);

            osc.setPeriodicWave(wave);
            osc.frequency.value = 440;
            osc.connectNode(context.destination);
            new Timer(new Duration(milliseconds: 60), () => osc.disconnect());

    }

    void drawOrbit(double point_x, double point_y) {
        List<Result> orbits = getOrbit(point_x, point_y, fractals[fractalChoiceIndex]);
        beep(orbits);
        path.attributes["stroke"] = "#ff0000";
        path.attributes["stroke-width"] = "1";
        String pathString = "";

        for(Result res in orbits) {
            double x = res.realComponentOfResult*width+width;
            double y = res.imaginaryComponentOfResult*height+height/2;
            if(pathString.isEmpty) {
                pathString = "M $x,$y";
            }
            pathString = "${pathString} L${x},${y} M${x},${y}";
        }
        pathString = "$pathString Z";
        path.attributes["d"] = pathString;
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

        return new Result(res.iteration + 1,tempRealComponent, tempImaginaryComponent);
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

        return new Result(res.iteration +1, tempRealComponent, tempImaginaryComponent);
    }

    Result burning_ship(double x, double y, Result res) {
        double tempRealComponent = res.realComponentOfResult * res.realComponentOfResult
            - res.imaginaryComponentOfResult * res.imaginaryComponentOfResult
            + x;
        double tempImaginaryComponent = 2 * (res.realComponentOfResult * res.imaginaryComponentOfResult).abs()
            + y;

        return new Result(res.iteration + 1,tempRealComponent, tempImaginaryComponent);
    }

    List<Result> getOrbit(double x, double y, dynamic equation) {
        List<Result> orbits = new List<Result>();
        Result ongoingResult = new Result(0,x,y);
        for(var i = 0; i < maxOrbitIterations; i++) {
            ongoingResult = equation(x,y,ongoingResult);
            if(ongoingResult.realComponentOfResult is num && ongoingResult.imaginaryComponentOfResult is num) {
                //plz no infinity for graphics OR sound
                orbits.add(ongoingResult);
            }
            // Return a number as a percentage
            if(ongoingResult.realComponentOfResult * ongoingResult.imaginaryComponentOfResult > 5)
                return orbits;
        }
        return orbits;
    }

    double checkIfBelongsToSet(double x, double y, dynamic equation) {
        Result ongoingResult = new Result(0,x,y);
        for(var i = 0; i < maxDrawIterations; i++) {
            ongoingResult = equation(x,y,ongoingResult);
            // Return a number as a percentage
            if(ongoingResult.realComponentOfResult * ongoingResult.imaginaryComponentOfResult > 5)
                return (i/maxDrawIterations * 100);
        }
        return 0.0;   // Return zero if in set
    }

    void render(num placeholder) {
        CanvasRenderingContext2D ctx = canvas.context2D;
        for(int x=0; x < canvas.width; x++) {
            for(int y=0; y < canvas.height; y++) {
                double belongsToSet =
                checkIfBelongsToSet(x/magnificationFactor - panX,
                    y/magnificationFactor - panY, fractals[fractalChoiceIndex]);

                if(belongsToSet == 0) {
                    ctx.fillStyle = '#000';
                    ctx.fillRect(x,y, 1,1); // Draw a black pixel
                } else {
                    ctx.fillStyle = 'hsl(0, 100%, ${belongsToSet/10}%)';
                    ctx.fillRect(x,y, 1,1); // Draw a colorful pixel
                }
            }
        }
    }
}


class Result {
    int iteration = 0;
    double realComponentOfResult;
    double imaginaryComponentOfResult;
    Result(int this.iteration, double this.realComponentOfResult, double this.imaginaryComponentOfResult) {
        //preserve sign but don't let get too big
        int cap = 1000;
        if(realComponentOfResult.abs() > cap) {
            realComponentOfResult = cap* realComponentOfResult/realComponentOfResult.abs();
        }
        if(imaginaryComponentOfResult.abs() > cap) {
            imaginaryComponentOfResult = cap * imaginaryComponentOfResult/imaginaryComponentOfResult.abs();
        }

    }
    @override
    String toString() => "$iteration: ($realComponentOfResult, $imaginaryComponentOfResult)";
}