COM = 'COM6';

a = ExperimentClass_GUI_LEDboard(COM); %create an object of the class to use it

 start = tic;
 a.sendPhaseParams("N", "red", 6, 1);
 a.turnOnLED(); 
%a.turnOffLED();

 a.clearLEDs();
 toc(start)

 a.endSerial();