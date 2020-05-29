#include <FastLED.h>

#define N_Strip 30 //bluewhite

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*Define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23

CRGB leds_Strips[NUM_LEDS_PER_STRIP];

void setup() {
  //setup LED strip
  FastLED.addLeds<LED_TYPE, N_Strip, COLOR_ORDER>(leds_Strips, NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness( BRIGHTNESS );
  //clear all LEDs, set them to black
  FastLED.clear();
  FastLED.show();
  //short wait
  delay(1000);
  leds_Strips[5] = CRGB::Red;
  //display changes (show color change)
  FastLED.show();
  delay(1000);
  FastLED.clear();
  FastLED.show();
}

void loop() {
//  //set LED to red
//  leds_Strips[5] = CRGB::Red;
//  //display changes (show color change)
//  FastLED.show();
//  //wait 1 sec
//  delay(500);
//  //clear all LEDs
//  FastLED.clear();
//  FastLED.show();
//  //wait 1 sec
//  delay(500);
}
