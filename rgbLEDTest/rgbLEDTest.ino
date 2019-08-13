int ledDelay = 1000;

#define RED 3
#define BLUE 5
#define GREEN 6

void setup() {
  pinMode(RED, OUTPUT);
  pinMode(BLUE, OUTPUT);
  pinMode(GREEN, OUTPUT);

  Serial.begin(9600);
}

void loop() {
  int ledColor = random(3);
  Serial.println(ledColor);
  switch (ledColor) {
    case 0://RED
      digitalWrite(RED, LOW);
      delay(ledDelay);
      digitalWrite(RED, HIGH);
      break;
    case 1://BLUE
      digitalWrite(BLUE, LOW);
      delay(ledDelay);
      digitalWrite(BLUE, HIGH);
      break;
    case 2://GREEN
      digitalWrite(GREEN, LOW);
      delay(ledDelay);
      digitalWrite(GREEN, HIGH);
      break;
  }
}
