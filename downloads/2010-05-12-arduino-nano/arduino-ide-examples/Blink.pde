// Programa de pruebas para que parpadee el led del arduino nano 
// Ejemplo para el entorno de Arduino
// Tomado de los ejemplos de arduino                             

int ledPin =  13;    // LED connected to digital pin 13

// The setup() method runs once, when the sketch starts

void setup()   {                
  // initialize the digital pin as an output:
  pinMode(ledPin, OUTPUT);     
}

void loop()                     
{
  digitalWrite(ledPin, HIGH);   // set the LED on
  delay(500);                  // wait for a second
  digitalWrite(ledPin, LOW);    // set the LED off
  delay(500);                  // wait for a second
}
