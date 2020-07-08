function [ai, dio] = krConnectDAQInf()
% start daq session
%ai = daq.createSession('mcc'); %measurement computing daq card
ai = daq.createSession('ni'); %national instruments daq card

ai.IsContinuous = true;
ai.Rate = 5000;  
ai.NotifyWhenDataAvailableExceeds = 25;
%durationInSeconds = 1; % one second of data per trigger
%ai.SamplesPerTrigger = ai.Rate; % one second of data per trigger

cha = addAnalogInputChannel(ai,'Dev2',[0:3],'Voltage');
prepare(ai);

dio = daq.createSession('ni'); 
chd = addDigitalChannel(dio, 'Dev2', {'port0/line0','port0/line1', 'port0/line2'},'OutputOnly');
global outputValue
outputValue = zeros(size(dio.Channels));
% addTriggerConnection(ai,'External','Dev1/PFI0','StartTrigger');
% % %set(ai,'TriggerRepeat',inf); % as soon as buffer filled, trigger again
% ai.TriggersPerRun = Inf; 
lh = addlistener(ai,'DataAvailable',@buffData); 

try
    startBackground(ai); 
catch
    stop(ai);
    startBackground(ai); 
end
    
%plot(timestamp, data)     
% trigger(ai); % begin running and logging

% output connections
% dio = digitalio('mcc');
% addDigitalChannel(dio, 0, 'out'); % reward line
% addDigitalChannel(dio, 2, 'out'); % trial triggers

end
