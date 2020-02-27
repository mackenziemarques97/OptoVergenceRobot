#include <FastLED.h>

#define photodiode 52
#define N_Strip 30 //bluewhite

#define BRIGHTNESS  100 /* valid values between 0 and 255 */
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

/*Define number of LEDs in each direction strip*/
#define NUM_LEDS_PER_STRIP 23

CRGB leds_Strips[NUM_LEDS_PER_STRIP];



void setup() {
//  FastLED.addLeds<LED_TYPE, N_Strip, COLOR_ORDER>(leds_Strips, NUM_LEDS_PER_STRIP).setCorrection( TypicalLEDStrip );
//  FastLED.setBrightness( BRIGHTNESS );
  pinMode(photodiode, OUTPUT);
  pinMode(N_Strip, OUTPUT);
  
//  leds_Strips[0] = CRGB::Black;
//  FastLED.show();
  digitalWrite(N_Strip, HIGH);
  
  digitalWrite(photodiode, HIGH);
  digitalWrite(photodiode, LOW);
  delay(100);
  
}

void loop() {
  digitalWrite(photodiode, HIGH);

  digitalWrite(N_Strip, LOW);
  delay(1000);
  digitalWrite(N_Strip, HIGH);
  delay(1000);
//  leds_Strips[0] = CRGB::White;
//  FastLED.show();
}
