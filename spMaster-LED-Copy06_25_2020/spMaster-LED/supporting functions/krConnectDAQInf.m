function [ai, dio] = krConnectDAQInf(data_main_dir)
% start daq session
% create analog input object
% create session with national instruments daq card
ai = daq.createSession('ni'); 

% set/change object properties
ai.IsContinuous = true;
ai.Rate = 5000;  
ai.NotifyWhenDataAvailableExceeds = 25;

cha = addAnalogInputChannel(ai,'Dev2',(0:5),'Voltage');
prepare(ai);

% create digital input/output object
% create session with national instruments daq card
dio = daq.createSession('ni'); 
chd = addDigitalChannel(dio, 'Dev2', {'port0/line0','port0/line1', 'port0/line2'},'OutputOnly');

global outputValue
outputValue = zeros(size(dio.Channels));
global fw
fw = fopen(fullfile(data_main_dir,'Data.bin'),'w');
lh = addlistener(ai,'DataAvailable',@(src,event) buffData(src,event)); 

try
    startBackground(ai); 
catch
    stop(ai);
    startBackground(ai); 
end

end
