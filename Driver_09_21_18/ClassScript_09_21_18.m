a = ExperimentClass08_29_18('COM8');

a.linearOscillate(10,10,60,25,30,2,100);

a.moveTo(90,45,500);

a.calibrate();

a.smoothPursuit(54000,60,-60,20,1000);

a.calibrate();

a.endSerial();