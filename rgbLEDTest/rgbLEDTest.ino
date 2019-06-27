int ledDelay = 1000;

#define RED 8
#define BLUE 9
#define GREEN 10

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
      digitalWrite(RED, HIGH);
      delay(ledDelay);
      digitalWrite(RED, LOW);
      break;
    case 1://BLUE
      digitalWrite(BLUE, HIGH);
      delay(ledDelay);
      digitalWrite(BLUE, LOW);
      break;
    case 2://GREEN
      digitalWrite(GREEN, HIGH);
      delay(ledDelay);
      digitalWrite(GREEN, LOW);
      break;
  }
}
