 #include <FastLED.h>

#define LED_PIN1    43
#define LED_PIN2    44
#define LED_PIN3    45
#define LED_PIN4    46
#define LED_PIN5    47
#define LED_PIN6    48
#define LED_PIN7    42
#define LED_PIN8    41
#define LED_PIN9    40



#define NUM_LEDS    23
#define BRIGHTNESS  64
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];


#define UPDATES_PER_SECOND 100


void setup() {
  delay( 3000 ); // power-up safety delay
  FastLED.addLeds<LED_TYPE, LED_PIN1, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN2, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN3, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN4, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN5, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN6, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN7, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN8, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.addLeds<LED_TYPE, LED_PIN9, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
  FastLED.setBrightness(  BRIGHTNESS );

}

void loop() {
  fill_solid(leds, NUM_LEDS, CRGB::Red);
  FastLED.show();
  delay(3000);
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.show();
  delay(500);
  
  fill_solid(leds, NUM_LEDS, CRGB::Blue);
  FastLED.show();
  delay(3000);
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.show();
  delay(500);
  
  fill_solid(leds, NUM_LEDS, CRGB::Green);
  FastLED.show();
  delay(3000);
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.show();
  delay(500);

  fill_solid(leds, NUM_LEDS, CRGB::Gray);
  FastLED.show();
  delay(3000);
  fill_solid(leds, NUM_LEDS, CRGB::Black);
  FastLED.show();
  delay(500);
}
