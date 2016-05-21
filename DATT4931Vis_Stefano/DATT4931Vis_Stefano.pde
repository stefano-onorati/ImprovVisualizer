import ddf.minim.analysis.*;
import ddf.minim.*;
import oscP5.*;
import netP5.*;

Minim minim;
AudioPlayer song;
//AudioInput in;
FFT fftLog;
OscP5 osc;


float audioThresh = 0.90;
float[] circles = new float[29];
float DECAY_RATE = random(5);

//all values used by touchOsc controller (default at 0 = black)

//colour values for ellipses
int redE = int(random(255)), greenE = int(random(255)), blueE = int(random(255));
//colour values for ellipse stroke
int redS = int(random(255)), greenS = int(random(255)), blueS = int(random(255));
//weight of ellipse stroke
int weightS = int(random(50));
String[] songs = {"Local Forecast - Elevator.mp3", "Aurea Carmina.mp3", "Night on the Docks - Sax.mp3"};

void setup()
{
  fullScreen();
  //size(displayWidth, displayHeight, P3D);
  frameRate(60);
  minim = new Minim(this);
  osc = new OscP5(this, 8000);
  song = minim.loadFile(songs[int(random(3))], 2048);
  song.play();
  //in = minim.getLineIn(Minim.STEREO, 2048);
  fftLog = new FFT(song.bufferSize(), song.sampleRate());
  //fftLog = new FFT(in.bufferSize(), in.sampleRate());
  fftLog.logAverages( 22, 3);


  noFill();
  ellipseMode(RADIUS);
}

void draw()
{
  background(0);
  pushMatrix();

  // Push new audio samples to the FFT
  //fftLog.forward(in.mix);
  fftLog.forward(song.mix); 
  
  //colour values for frequency wave lines
  int redW = (redE + redS)/2, greenW = (greenE + greenS)/2, blueW = (blueE + blueS)/2;
  stroke(redW,greenW,blueW);
  strokeWeight(2);
  
  //for(int i = 0; i < in.bufferSize() - 1; i++)
  //{
  //  line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
  //  line(i, (displayHeight-50) + in.right.get(i)*50, i+1, (displayHeight-50) + in.right.get(i+1)*50);
  //}
  
   for (int i = 0; i < song.bufferSize() - 1; i++)
   {
    line(i, 50 + song.left.get(i)*50, i+1, 50 + song.left.get(i+1)*50);
    line(i, (displayHeight-50) + song.right.get(i)*50, i+1, (displayHeight-50) + song.right.get(i+1)*50);
   }

  // Loop through frequencies and compute width for ellipse stroke widths, and amplitude for size
  for (int i = 0; i < 29; i++) 
  {

    // What is the average height in relation to the screen height?
    float amplitude = fftLog.getAvg(i);

    // If we hit a threshhold, then set the circle radius to new value
    if (amplitude <= audioThresh) 
      circles[i] = amplitude*(displayHeight/2.5);
    else 
      // Otherwise, decay slowly
    circles[i] = max(0, min(displayHeight/2.5, circles[i]-DECAY_RATE));

    pushStyle();
    // Calculate the gray value for this circle
    stroke(redS, greenS, blueS, map(amplitude, 0, 10, 0, 255));
    fill(redE, greenE, blueE, map(amplitude, 0, 10, 0, 255));
    strokeWeight(weightS);

    // Draw an ellipse for this frequency
    ellipse(displayWidth/2, displayHeight/2, circles[i], circles[i]);

    popStyle();
  }

  popMatrix();
}

private void oscEvent(OscMessage msg)
{
  String addr = msg.addrPattern();

  if (addr.equals("/1/rotary1"))
  {
    float c = msg.get(0).floatValue();
    redE = (int) c;
  } 
  else if (addr.equals("/1/rotary2"))
  {
    float c = msg.get(0).floatValue();
    greenE = (int) c;
  } 
  else if (addr.equals("/1/rotary3"))
  {
    float c = msg.get(0).floatValue();
    blueE = (int) c;
  } 
  else if (addr.equals("/1/rotary4"))
  {
    float c = msg.get(0).floatValue();
    redS = (int) c;
  } 
  else if (addr.equals("/1/rotary5"))
  {
    float c = msg.get(0).floatValue();
    greenS = (int) c;
  } 
  else if (addr.equals("/1/rotary6"))
  {
    float c = msg.get(0).floatValue();
    blueS = (int) c;
  } 
  else if (addr.equals("/1/rotary7"))
  {
    float c = msg.get(0).floatValue();
    weightS = (int) c*2;
  } 
  else if (addr.equals("/1/fader1"))
    DECAY_RATE = msg.get(0).floatValue()/2;
  else if (addr.equals("/1/push1"))
    exit();
}

//boolean sketchFullScreen() 
//{
//  return true;
//}

void stop()
{
  //in.close();
  song.close();
  minim.stop();
  super.stop();
}

void keyPressed() 
{
  if (key==' ') exit();
  if (key=='s') saveFrame("###.jpeg");
}