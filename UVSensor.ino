/*
  Vera Arduino UVM-30A

  connect the sensor as follows :

  +   >>> 5V
  -   >>> GND
  out >>> A0     
  
  Contribution: epierre
 
*/

#include <Sleep_n0m1.h>
#include <SPI.h>
#include <RF24.h>
#include <EEPROM.h>  
#include <Sensor.h>  
#include <Wire.h> 

#define CHILD_ID_UV 0
#define UV_SENSOR_ANALOG_PIN 0
unsigned long SLEEP_TIME = 30; // Sleep time between reads (in seconds)

Sensor gw;
Sleep sleep;
int lastuv;

void setup()  
{ 
  gw.begin();

  // Send the sketch version information to the gateway and Controller
  gw.sendSketchInfo("UV Sensor", "1.0");

  // Register all sensors to gateway (they will be created as child devices)
  gw.sendSensorPresentation(CHILD_ID_UV, S_UV);

}

void loop()      
{     
  uint16_t auv = analogRead(0);// Get UV value
  uint16_t uv=0;
  Serial.println(auv);
  if (auv<10) {uv=0;}
  else if ((auv>=10) and(auv<46))  {uv=1;}
  else if ((auv>=46) and(auv<65))  {uv=2;}
  else if ((auv>=65) and(auv<83))  {uv=3;}
  else if ((auv>=83) and(auv<103)) {uv=4;}
  else if ((auv>=103)and(auv<124)) {uv=5;}
  else if ((auv>=124)and(auv<142)) {uv=6;}
  else if ((auv>=142)and(auv<162)) {uv=7;}
  else if ((auv>=162)and(auv<180)) {uv=8;}
  else if ((auv>=180)and(auv<200)) {uv=9;}
  else if ((auv>=200)and(auv<221)) {uv=10;}
  else if (auv>=221)              {uv=11;}
  if (uv != lastuv) {
      gw.sendVariable(CHILD_ID_UV, V_UV, uv);
      lastuv = uv;
  }
  
  // Power down the radio.  Note that the radio will get powered back up
  // on the next write() call.
  delay(1000); //delay to allow serial to fully print before sleep
  gw.powerDown();
  sleep.pwrDownMode(); //set sleep mode
  sleep.sleepDelay(SLEEP_TIME * 1000); //sleep for: sleepTime 
}
