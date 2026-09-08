#/usr/bin/bash

cd frame
ls frame*.ppm > l.list
ppm2fli -N -g 400x300 -s12 l.list movie.fli
mencoder movie.fli -ovc lavc -o test.avi
