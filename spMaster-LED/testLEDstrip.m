COM = 'COM6';

a = ExperimentClass_GUI_LEDboard(COM); %create an object of the class to use ita = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use it

% a.sendPhaseParams("N", "red", 6, 1);
% a.turnOnLED(); 
% a.turnOffLED();
% 
% a.clearLEDs();

a.endSerial();