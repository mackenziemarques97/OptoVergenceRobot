function [eyePosX eyePosY] = krPeekEyePos(ai)

% this file is in krPlotEPos
global buffData
pause(.001);
d = buffData;

eyePosX = d(end,1)*100; % scaling from volts to deg
eyePosY = d(end,2)*100; % scaling from volts to deg
