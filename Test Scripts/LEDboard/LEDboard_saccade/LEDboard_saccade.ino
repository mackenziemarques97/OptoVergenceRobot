#include <stdio.h>
#include <math.h>
#include <FastLED.h>

#define BRIGHTNESS  64
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*define number of direction strips*/
#define NUM_STRIPS 8
/*define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23
/*define one LED in the center*/
#define NUM_Center 1

/*LED pins on Arduino for each direction strip*/
#define N_Strip 40
#define NW_Strip 41
#define NE_Strip 42
#define S_Strip 43
#define SW_Strip 44
#define SE_Strip 45
#define W_Strip 46
#define E_Strip 47
/*LED pin on Arduino for center LED*/
#define Center 48

/*create an array of LED arrays*/
CRGB leds_Strips[NUM_STRIPS][NUM_LEDS_PER_STRIP];
/*create an array for center LED*/
CRGB leds_Center[NUM_Center];
/*declare String object where input commands are read into*/
String str;

void setup() {
  Serial.begin(9600);
  
  delay( 3000 );
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
}

void loop() {
  Serial.flush();
  str = Serial.readString();
  
  if (str != NULL){
    leds_Center[0] = CRGB::Red; FastLED.show();
    delay(2500);
    leds_Center[0] = CRGB::Black; FastLED.show();
    leds_Strips[2][10] = CRGB::Green; FastLED.show();
    delay(2500);
    leds_Strips[2][10] = CRGB::Black; FastLED.show(); 
  }
}
