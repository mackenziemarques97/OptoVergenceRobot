/*leds[0] refers to 1st LED, leds[10] refers to 11th LED

   different cases for
*/

#include <FastLED.h>

#define N_LED_PIN   40
#define NE_LED_PIN   41
#define E_LED_PIN   42
#define SE_LED_PIN   43
#define S_LED_PIN   44
#define SW_LED_PIN   45
#define W_LED_PIN   46
#define NW_LED_PIN   47
#define Center_LED_PIN   48

#define NUM_LEDS    23 /*except for center, every direction has 23 LEDs*/
#define BRIGHTNESS  64
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB N_leds[NUM_LEDS];
CRGB NE_leds[NUM_LEDS];
CRGB E_leds[NUM_LEDS];
CRGB SE_leds[NUM_LEDS];
CRGB S_leds[NUM_LEDS];
CRGB SW_leds[NUM_LEDS];
CRGB W_leds[NUM_LEDS];
CRGB NW_leds[NUM_LEDS];
CRGB Center_leds[NUM_LEDS];

bool questionPrinted = false;

void setup() {
  delay( 3000 ); // power-up safety delay
  FastLED.addLeds<LED_TYPE, N_LED_PIN, COLOR_ORDER>(N_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NE_LED_PIN, COLOR_ORDER>(NE_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, E_LED_PIN, COLOR_ORDER>(E_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SE_LED_PIN, COLOR_ORDER>(SE_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, S_LED_PIN, COLOR_ORDER>(S_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, SW_LED_PIN, COLOR_ORDER>(SW_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, W_LED_PIN, COLOR_ORDER>(W_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, NW_LED_PIN, COLOR_ORDER>(NW_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, Center_LED_PIN, COLOR_ORDER>(Center_leds, NUM_LEDS).setCorrection( TypicalLEDStrip );

  FastLED.setBrightness(  BRIGHTNESS );
  Serial.begin(9600);

}

void loop() {
  Serial.flush();
  String ent = Serial.readString();

  if (questionPrinted == false) {
    Serial.println("Direction?");
    questionPrinted = true;
  }
  else if (questionPrinted == true){
    Serial.println(ent);
    }
  }

  /*Add direction and degree entry*/
  //Serial.println("Direction?");
  //Serial.println("Degree?");

  //NW_leds[5] = CRGB::Pink; FastLED.show(); //delay(100);
  //SW_leds[5] = CRGB::Black; FastLED.show(); delay(100);
