//--------------------------------------------------------------
//-- ArduSnake library: Locomotion of modular snake robots
//-----------------------------------------------------------
//-- Layer: Oscillator
//------------------------------------------------------------
//-- Example of use of the Oscillator layer
//--
//-- Example 3: Two servos oscillating independenly, with different
//--  parameters
//--------------------------------------------------------------
//-- (c) Juan Gonzalez-Gomez (Obijuan), Feb-2012
//-- GPL license
//--------------------------------------------------------------
#include <Servo.h>
#include <Oscillator.h>
#include "skymega.h"

//-- Declare two oscillators
Oscillator osc[3];

const int T = 3000;
const int Av = 20;
const int Ah = 40;
const int Phi_ini = 0;

void setup()
{
  //-- Attach the oscillators to the two servos
  //-- SERVO 2 and SERVO 4 for the skymega
  //-- If using arduino, you can use the pin numbers (8 and 9 for example)
  osc[0].attach(SERVO2);
  osc[1].attach(SERVO4);
  osc[2].attach(SERVO6);
  

  //-- Configure the oscillators
  //-- Oscillator 0
  osc[0].SetPh(DEG2RAD(0 + Phi_ini));
  osc[0].SetO(0);
  osc[0].SetA(20);
  osc[0].SetT(T);
  
  //-- Oscillator 1
  osc[1].SetPh(DEG2RAD(90 + Phi_ini));
  osc[1].SetO(0);
  osc[1].SetA(40);
  osc[1].SetT(T);
  
  //-- Configure the oscillators
  //-- Oscillator 0
  osc[2].SetPh(DEG2RAD(120 + Phi_ini));
  osc[2].SetO(0);
  osc[2].SetA(20);
  osc[2].SetT(T);

}

void loop()
{
  //-- Refresh the oscillators
  for (int i=0; i<3; i++)
    osc[i].refresh(); 
}


