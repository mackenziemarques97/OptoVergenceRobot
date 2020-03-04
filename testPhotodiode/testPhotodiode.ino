#include <FastLED.h>

/*Include the following libraries*/
#include <stdio.h>
#include <math.h>
#include <FastLED.h>

/*Define pins for interacting with photodiode*/
#define cReset 50
#define dLatchOut 51

/*Define LED pins on Arduino for each direction strip*/
#define N_Strip 30 //bluewhite
#define NW_Strip 31 //yellowblack
#define NE_Strip 32 //black
#define S_Strip 33 //purple
#define SW_Strip 34 //greenwhite
#define SE_Strip 35 //brown
#define W_Strip 36 //white
#define E_Strip 37 //blue
/*Define LED pin on Arduino for center LED*/
#define Center 38 //brownblack

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*Define number of direction strips*/
#define NUM_STRIPS 8
/*Define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23
/*Define one LED in the center*/
#define NUM_Center 1

/*Create an array of LED arrays to represent the direction strips*/
/*CRGB is an object representing a color in RGB color space*/
CRGB leds_Strips[NUM_STRIPS][NUM_LEDS_PER_STRIP];
/*Create an array for center LED*/
CRGB leds_Center[NUM_Center];



void setup() {
  FastLED.addLeds<LED_TYPE, N_Strip, COLOR_ORDER>(leds_Strips[0], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NW_Strip, COLOR_ORDER>(leds_Strips[1], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NE_Strip, COLOR_ORDER>(leds_Strips[2], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, S_Strip, COLOR_ORDER>(leds_Strips[3], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SW_Strip, COLOR_ORDER>(leds_Strips[4], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SE_Strip, COLOR_ORDER>(leds_Strips[5], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, W_Strip, COLOR_ORDER>(leds_Strips[6], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, E_Strip, COLOR_ORDER>(leds_Strips[7], NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, Center, COLOR_ORDER>(leds_Center, NUM_Center).setCorrection( TypicalLEDStrip );

  FastLED.setBrightness( BRIGHTNESS );
  pinMode(cReset, OUTPUT);
  
  FastLED.clear();
  FastLED.show();
  
  digitalWrite(cReset, HIGH);
  digitalWrite(cReset, LOW);
  delay(100);
  
}

void loop() {
  digitalWrite(cReset, HIGH);

  leds_Strips[6][0] = CRGB::Blue;
  leds_Strips[6][10] = CRGB::Blue;
  leds_Strips[6][22] = CRGB::Red;
  FastLED.show();
  delay(1000);

  digitalWrite(cReset, LOW);

  FastLED.clear();
  FastLED.show();
  delay(1000);
}
