/*leds[0] refers to 1st LED, leds[10] refers to 11th LED
 * 
 */

#include <FastLED.h>

#define LED_PIN     40
#define NUM_LEDS    23
#define BRIGHTNESS  64
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];

void setup() {
  delay( 3000 ); // power-up safety delay
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(  BRIGHTNESS );
}

void loop() {
  leds[0] = CRGB::Green; FastLED.show(); //delay(100);
  //leds[5] = CRGB::Black; FastLED.show(); delay(100);
}
