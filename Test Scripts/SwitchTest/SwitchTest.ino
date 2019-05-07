#define xMin 2
#define xMax 3
#define yMin 4
#define yMax 5

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  pinMode(xMin,INPUT);
  pinMode(xMax,INPUT);
  pinMode(yMin,INPUT);
  pinMode(yMax,INPUT);
  digitalWrite(xMin,HIGH);
  digitalWrite(xMax,HIGH);
  digitalWrite(yMin,HIGH);
  digitalWrite(yMax,HIGH);

}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.println("New");
  Serial.println(digitalRead(xMin));
  Serial.println(digitalRead(xMax));
  Serial.println(digitalRead(yMin));
  Serial.println(digitalRead(yMax));
  delay(1000);
}
