serialPort = 'COM8';
a = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use ita = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use it

% a.clearLEDs();
% 
% a.sendPhaseParams("N", "red", 6, 3);
% 
% a.showLEDs(); 

a.endSerial();