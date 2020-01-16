serialPort = 'COM6'; %format like this
a = ExperimentClass_GUI_LEDboard(serialPort); %create an object of the class to use it

pause(2);

a.sendPhaseParams("N","green",3,3);
a.showLEDs();