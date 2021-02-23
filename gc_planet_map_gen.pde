/*
    GreatCircle Planet Map Generator
    
    This program generates 1000 x 500 equirectangular heightmaps for
    fictional planets. A sphere projected onto an equirectangular map
    is cut by a random 3d plane passing through its origin. One side
    of the sphere is raised, the other lowered. The process is repeated 
    until a fractal terrain is generated. The result can be saved as png.
    Copyright (C) 2020  Marco Amerotti

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

//where to draw map and gui
PGraphics map;
PGraphics gui;


//some constants & variables
final int HEIGHT = 500;
final int MAP_W = 1000;
final int MAP_H = HEIGHT;
final int GUI_W = 300;
final int GUI_H = HEIGHT;

boolean inGui = true;
boolean pause = true;

final color GUI_COLOR = 220;
final color RED = color(255, 0, 0);

//using settings to instantiate size with variables
void settings(){
  size(MAP_W+GUI_W, HEIGHT);
}

//user interaction
void keyPressed(){
  if(inGui){
    //exit setup
    if(key == ' '){
      inGui = false;
      pause = false;
    } 
    //iterations
    else if(key == '+' || key == ']') steps += 100;
    else if((key == 'è' || key == '[') && steps > 100) steps -= 100;
  } 
  else if(key == 'r'){
    //reset
    inGui = true;
    pause = true;
    count = 0;
    steps = 1000;
    for(int i = 0; i < H.length; i++) H[i] = 0;
    map.loadPixels();
    for(int i = 0; i < map.pixels.length; i++) map.pixels[i] = color(255);
    map.updatePixels();
  }
  else {
    //pause
    if(key == ' ') pause = !pause;
    if(pause){
      //save
      if(key == 's') selectOutput("Export map as png...", "fileSelected");
    }
  }
  key = '\\';
}

//choose file output
void fileSelected(File f){
  map.save(f.getAbsolutePath()+".png");
}

//some other variables
int steps = 1000;
int count = 0;
float max = 0;
float min = 0;

//the matrix which holds the height values
float H[];

void setup(){
  background(255);
  surface.setTitle("Open GC Planet Map Generator");
  map = createGraphics(MAP_W, MAP_H);
  gui = createGraphics(GUI_W, GUI_H);
  //init matrix
  H = new float[width*height];
  for(int i = 0; i < H.length; i++) H[i] = 0;
}

void draw(){
  gui.beginDraw();
  map.beginDraw();
  gui();
  if(count < steps && !pause){
    map.loadPixels();
    //choose a random plane
    float ran = random(1);
    float a = myTan(random(PI));
    float b = myTan(random(PI));
    //for every pixel in the projection
    for(int x = 0; x < map.width; x++){
      for(int y = 0; y < map.height; y++){
        //transform to spherical coordinates
        float ph = (TWO_PI*x)/map.width;
        float th = (PI*y)/map.height;
        //tranform to 3d cartesian coordinates
        float sinth = mySin(th);
        float x3d = sinth*myCos(ph);
        float y3d = sinth*mySin(ph);
        float sz = myCos(th);
        //calculate plane z coordinate at 3d x and y
        float pz = planeEq(x3d,y3d, a, b);
        int index = y*map.width+x;
        //select upper or lower part of the sphere
        if(ran > 0.5) sz*=-1;
        //raise selected part
        if(sz > pz){
          H[index] += 0.1;
          if(H[index] > max) max = H[index];
        } else {
          //lower the other part
          H[index] -= 0.1;
          if(H[index] < min) min = H[index];
        }
        map.pixels[index] = color(((H[index]-min)/(max-min))*255);
      }
    }
   map.updatePixels();
   count++;
  } 
  //pause when finished
  if(count == steps-1) {
    pause = true;
    count++;
  }
  map.endDraw();
  gui.endDraw();
  image(gui, 0, 0);
  image(map, GUI_W, 0);
}

//draw gui
void gui(){
  gui.background(GUI_COLOR);
  gui.rectMode(CENTER);
  gui.noFill();
  gui.stroke(0);
  gui.rect(GUI_W/2, GUI_H/2, GUI_W, GUI_H);
  
  gui.textAlign(CENTER);
  guiText("GC Planet Map Generator", 22, 0, GUI_W/2, GUI_H/9);
  guiText("ITERATIONS: " + steps, 17, 0, GUI_W/2, 130);
  guiText("(press [ / ] to decrease/increase)", 15, 0, GUI_W/2, 160);
  guiText("PRESS SPACE TO START/PAUSE", 15, 0, GUI_W/2, 200);
  guiText("When in pause, press \"s\" to save", 15, 0, GUI_W/2, 230);
  guiText("Press \"r\" to reset", 15, 0, GUI_W/2, 260);
  guiText("Copyright (C) 2020  Marco Amerotti", 10, 0, GUI_W/2, 490);
  
  if(pause) guiText("PAUSE", 17, RED, GUI_W/2, 300);
  if(!inGui){
    if(count%(steps/100) <= count%(steps/10)*10)
    guiText((int)((float)count/steps*100) + " % complete", 17, 0, GUI_W/2, 350);
  }
  
  gui.textAlign(LEFT);
  guiText("ITERATIONS:  " + count, 17, 0, GUI_W/9, 400);
}

//shortcut to draw text on gui
void guiText(String s, int size, color c, int x, int y){
  gui.fill(c);
  gui.textSize(size);
  gui.text(s, x, y);
}

//z coordinate of choosen plane at specific x and y
static float planeEq(float x, float y, float a, float b){
  return a*x+b*y;
}

//sin(x) using taylor approximation to improve performance 
static float mySin(float x){
  if(x >= 0 && x <= PI/2) return taylorSin(x);
  if(x > PI/2 && x <= PI) return taylorSin(PI-x);
  else return -mySin(x-PI);
}

//cos(x) using remapped sin(x)
static float myCos(float x){
  return mySin(x+HALF_PI);
}

//tan(x) using ratio between sine and cosine
static float myTan(float x){
  return mySin(x)/myCos(x);
}

//taylor approximation of sin(x) to fifth degree
static float taylorSin(float x){
  float xcb = x*x*x;
  float xfiv = xcb*x*x;
  return x-(xcb/6)+xfiv/(120);
}

/* Copyright (C) 2020  Marco Amerotti */
