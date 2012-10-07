/*

 ----------------------------------------------------------------
 Copyright (C) 2012 IO10 
 based on original Sketch "lalana" by Ricard Marxer Piñón
 
 Copyright (C) 2005 Ricard Marxer Piñón
 
 ----------------------------------------------------------------
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 ----------------------------------------------------------------
 Built with Processing 1.5
 uses Geomerative 
 ----------------------------------------------------------------
 
 Created 6 October 2012
 
 ----------------------------------------------------------------
 REALCLOUD LOGO STUDIES
 ----------------------------------------------------------------
 
 */

import processing.opengl.*;
import geomerative.*;

float toldist;
RFont f;
RGroup grupo;
PFont fBlack;


boolean restart = false;
Particle[] psys;
int numPoints, numParticles;
float maxvel;

String [] colorlist;
String [] colors = new String[8];


//------------------------ Runtime properties ----------------------------------
// Save each frame
boolean SAVEVIDEO = false;
boolean SAVEFRAME = true;
boolean APPLICATION = true;

String DEFAULTAPPLETRENDERER = P3D;
int DEFAULTAPPLETWIDTH = 680;
int DEFAULTAPPLETHEIGHT = 480;

String DEFAULTAPPLICRENDERER = OPENGL;
int DEFAULTAPPLICWIDTH = 800;
int DEFAULTAPPLICHEIGHT = 600;
//------------------------------------------------------------------------------


// Text to be written
String STRNG_1 = "Real";
String STRNG_2 = "Cloud";

String STRNG = STRNG_1+STRNG_2;

// Font to be used
//String FONT = "lucon.ttf";
String FONT = "frutigerbold.ttf";

// Rainbow when true, IO10 when false
boolean COLORHue = true;

// Velocity of change
int VELOCITY = 10;

// Color Background
int BG_COL = 255;

// Color STRNG_1 overlay
int STRNG_1_COL = 0;

// Color STRNG_2 overlay
int STRNG_2_COL = #ff0066;

// Velacity of deformation
float TOLCHANGE = 0.035;

// Coefficient that handles the variation of amount of ink for the drawing 
float INKERRCOEFF = 0.4;

// Coefficient that handles the amount of ink for the drawing
float INKCOEFF = 0.6;

// Coefficient of precision: 0 for lowest precision
float PRECCOEFF = 0.95;

String newString = "";

void setup(){

  int w = DEFAULTAPPLICWIDTH, h = DEFAULTAPPLICHEIGHT;
  String r = DEFAULTAPPLICRENDERER;
  
  RG.init(this);
  f = new RFont(FONT, 327, RFont.CENTER);
  
  fBlack = createFont(FONT, 173);
  textFont(fBlack);

  if(!APPLICATION){
    // Specify the widtha and height at runtime
    w = int(param("width"));
    h = int(param("height"));
    r = (String)param("renderer");


    // (String) will return null if param("renderer") doesn't exist
    if (r != OPENGL && r != P3D && r != JAVA2D && r != P2D) {
      r = DEFAULTAPPLETRENDERER;
    }
    // int() will return 0 if param("width") doesn't exist
    if (w <= 0) {
      w = DEFAULTAPPLETWIDTH;
    }
    // int() will return 0 if param("height") doesn't exist
    if (h <= 0) {
      h = DEFAULTAPPLETHEIGHT;
    }
  }

  size(w,h,r);
  frameRate(100);
  try{
    smooth();
  }
  catch(Exception e){
  }

  background(BG_COL);

  initialize();
}

void draw(){

  pushMatrix();
  translate(width/2, height/2);
  noStroke();

  for(int i=0;i<numParticles;i++){
    for(int j=0;j<VELOCITY;j++){
      psys[i].update(grupo);
      psys[i].draw(g);
    }
  }
  popMatrix();

  fill(STRNG_1_COL);
  textAlign(LEFT, CENTER);
  text(STRNG_1,-8, height/2);
  
  fill(STRNG_2_COL);
  textAlign(LEFT, CENTER);
  text(STRNG_2,width/2-65, height/2);
 

  if(SAVEVIDEO) saveFrame("filesvideo/"+STRNG+"-####.tga");
  toldist += TOLCHANGE;
}

void initialize(){
  toldist = ceil(width/200F) * (6F/(STRNG.length()+1));
  maxvel = width/80F * INKERRCOEFF * (6F/(STRNG.length()+1));

  grupo = f.toGroup(STRNG);
  
  RCommand.setSegmentStep(1-constrain(PRECCOEFF,0,0.99));
  RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  grupo = grupo.toPolygonGroup();
  grupo.centerIn(g, 5, 1, 1);


  background(BG_COL);
  
 

  
  RPoint[] ps = grupo.getPoints();
  numPoints = ps.length;
  numParticles = numPoints;
  psys = new Particle[numParticles];
  for(int i=0;i<numParticles;i++){
    //psys[i] = new Particle(g,i,int(float(i)/float(numParticles)*125));
    psys[i] = new Particle(g,i,int(float(i)/float(numParticles)*125));
    psys[i].pos = new RPoint(ps[i]);
    psys[i].vel.add(new RPoint(random(-10,10),random(-10,10)));
  } 

  toldist = 8;
}


void chooseRandomColor() {

  String[] colors = new String[5];
  
  // color palette - change here to try different palette
  colors[0] = "242,15,98";
  colors[1] = "255,154,46";
  colors[2] = "249,248,30";
  colors[3] = "143,210,42";
  colors[4] = "100,41,148";
  
  float d = random(4);
  int e = int(d);
  colorlist = split(colors[e], ',');  
}

public class Particle{
  // Velocity
  RPoint vel;

  // Position
  RPoint pos;
  RPoint lastpos;

  // Caracteristics
  int col;
  int hueval;
  float sz;

  // ID
  int id;

  // Constructor
  public Particle(PGraphics gfx, int ident, int huevalue){
    pos = new RPoint(random(-gfx.width/2,gfx.width/2), random(-gfx.height/2,gfx.height/2));
    lastpos = new RPoint(pos);
    vel = new RPoint(0, 0);
    
    if(COLORHue){
    colorMode(HSB);
    }else{
    colorMode(RGB);
    }
    
    sz = random(2,3);

    id = ident;
    hueval = huevalue;
  }

  // Updater of position, velocity and colour depending on a RGroup
  public void update(RGroup grp){
    lastpos = new RPoint(pos);
    pos.add(vel);
    RPoint[] ps = grp.getPoints();
    if(ps != null){
      float distancia = dist(pos.x,pos.y,ps[id].x,ps[id].y);
      if(distancia <= toldist){
        id = (id + 1) % ps.length;

      }

      RPoint distPoint = new RPoint(ps[id]);
      distPoint.sub(pos);

      distPoint.scale(random(0.028,0.029));
      vel.scale(random(0.5,1.3));
      vel.add(distPoint);
      float sat = constrain((width-distancia)*0.25,0.001,255);
      float velnorm = constrain(vel.norm(),0,maxvel);

      sat = abs(maxvel-velnorm)/maxvel*INKCOEFF*255;
      sat = constrain(sat,0,255);
        if(COLORHue){
        
          // Alpha value here changes the strenght of the particles originally = sat*(toldist/80)
         
         col = color(hueval,160,255,sat*(toldist/100));
         }else{     
         chooseRandomColor();
         
         // Alpha value here changes the strenght of the particles

         col = color(int(colorlist[0]),int(colorlist[1]),int(colorlist[2]),sat*(toldist/10));
      }
    }
  }

  public void setPos(RPoint newpos){
    lastpos = new RPoint(pos);
    pos = newpos;
  }

  // Drawing the particle
  public void draw(PGraphics gfx){
    stroke(col);
    line(lastpos.x,lastpos.y,pos.x, pos.y);
  }
}
