float pi = 3.14159265359;

void setup() {
  Serial.begin(9600);
  Serial.println("Hello");

  //angles inputted as visual degrees
  //90 degrees = 0 on unit circle, 0
  //-90 degrees = 180 on unit circle, 3.14
  int angInit = 90;
  int angFinal = -90;
  int arcRes = 10;
  int R = 20000;

  Serial.println("Old Way");
  float angInit_rad = (pi / 180) * (-(angInit) + 90); /*convert initial angle from degrees to radians*/
  float angFinal_rad = (pi / 180) * (-(angFinal) + 90); /*convert final angle from degrees to radians then adjust by input resolution*/
  float angInit_res = angInit_rad * arcRes;
  float angFinal_res = angFinal_rad * arcRes;
  
  //long dispInitx = dimensions[0] * 0.5 + ((float) R) * cos(angInit_rad) - location[0];
  //long dispInity = ((float) R) * sin(angInit_rad) - location[1];
  for (int i = angInit_res; i <= angFinal_res; i ++) { /*move from initial to final angle*/
    int dx = round(-R / (arcRes) * sin((float)i / (arcRes))); /*change in x-direction, derivative of rcos(theta) adjusted for resolution*/
    int dy = round(R / (arcRes) * cos((float)i / (arcRes))); /*change in y-direction, derivative of rsin(theta) adjusted for resolution*/
    Serial.print("i:"); Serial.println(i);
    Serial.print("dx:"); Serial.println(dx);
    Serial.print("dy:"); Serial.println(dy);
  }

  Serial.println("New Way");
  float incr = (angFinal_rad - angInit_rad) / arcRes;
  //long dispInitx = dimensions[0] * 0.5 + ((float) R) * cos(angInit_rad) - location[0];
  //long dispInity = ((float) R) * sin(angInit_rad) - location[1];
  for (int i = angInit_rad; i <= angFinal_rad; i = i + incr) { /*move from initial to final angle*/
    int dx = round(-R / (arcRes) * sin((float)i)); /*change in x-direction, derivative of rcos(theta) adjusted for resolution*/
    int dy = round(R / (arcRes) * cos((float)i)); /*change in y-direction, derivative of rsin(theta) adjusted for resolution*/
    Serial.print("i:"); Serial.println(i);
    Serial.print("dx:"); Serial.println(dx);
    Serial.print("dy:"); Serial.println(dy);
  }

  /*for (float i = angInit_rad; i <= angFinal_rad; i += incr){
    Serial.println(i);
    }*/

}

void loop() {

}
