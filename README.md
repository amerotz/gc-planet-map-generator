# gc-planet-map-generator
A simple map generator for fictional planets.

# How it works
This program generates 1000 x 500 equirectangular heightmaps for fictional planets. A sphere projected onto an equirectangular map is cut by a random 3d plane passing through its origin. One side of the sphere is raised, the other lowered. The process is repeated until a fractal terrain is generated. The result can be saved as a grayscale png image.

You can choose how many iterations the program has to do and you'll see the map emerge step by step. If you think the map is already good mid execution you can pause and save it as it is.

# Installation
This program is written in Processing 3.5.4 (https://www.processing.org/). You can either download the Processing editor (https://www.processing.org/download/) and open the sketch from there or try one of the executables (Windows & Linux only). An online version will be available soon. Java 8 or greater is required.
