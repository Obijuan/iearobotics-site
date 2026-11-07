//--------------------------------------------------------------
//-- Different oscillations for unimod
//-- When the test button is pressed, the oscillation is changed
//--------------------------------------------------------------
//-- (c) Juan Gonzalez-Gomez (Obijuan), Jul-2013
//-- GPL license
//--------------------------------------------------------------
#include <Servo.h>
#include <Oscillator.h>
#include "skymega.h"

const int T0 = 2000;
const int T1 = 1000;

//-- Sequence of movement for unimod
const int A[] = {0,  40, 80,  40,  40,  40,  40};
const int O[] = {0,  0,   0,   0,   0,   0,  40};
const int T[] = {T0, T0, T0,  T0,   T1, T0,  T0};

//-- Number of elements in the sequence
int seq_size = sizeof(A)/sizeof(int);
int seq = 0;  //-- Sequence counter

//-- Declare an oscillator
Oscillator osc;

void setup()
{
  //-- Attach the oscillator to the servo
  //-- For arduino, you can use the pin number instead of SERVO2 (for example 8)
  osc.attach(SERVO2);
  
  // The led is an output
  pinMode(LED, OUTPUT);      
  
  //-- The button is an input
  pinMode(BUTTON, INPUT);
  //-- Activate the button pull-up resistor
  digitalWrite(BUTTON, HIGH); 

  //-- Serial port is used for debuging
  Serial.begin(9600);   
  
}

//-- This function returns true when the test button
//-- is pressed
bool button_clicked()
{
  
  static int button=1;
  static int oldbutton=1;
  
  //-- Save the previous button state
  oldbutton=button;
  
  // read the button
  button = digitalRead(BUTTON);

  //-- Detect a change in the button
  if (button!=oldbutton) {
    delay(20); //-- for debouncing
    if (button==PRESSED)
      return true;
  } 
  
  return false;
}

//-- This function returns true when the time "time"
//-- has passed since the last call
bool timeout(long time)
{
  static long previousMillis = 0; 
  static long currentMillis;
  
  //-- Read current time
  currentMillis = millis();
 
  //-- Check if the timeout has passed
  if(currentMillis - previousMillis > time) {
    previousMillis = currentMillis;   

    return true;
  }
  
  return false;
}

//-- Led state
int ledState = OFF;

//-- Led blinking period, in ms
long period = 1000;

//-- The servo will oscillate with the
//-- default parameters
void loop()
{
  //-- Refresh the oscillator
  osc.refresh();
  
  if (button_clicked()) {
    Serial.println("clicked!");
    
    //-- Point to the next sequence
    seq = (seq + 1) % seq_size;
    Serial.println(seq, DEC);
    
    //-- Update the oscillator with the new sequence
    osc.SetO(O[seq]);
    osc.SetA(A[seq]);
    osc.SetT(T[seq]);
  }
}


