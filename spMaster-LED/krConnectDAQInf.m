 function [ai, dio] = krConnectDAQInf()
% connect to daq, start daq session, and run continuously

%ai = daq.createSession('mcc'); %creates session object measurement
%computing daq card on analog input channel
ai = daq.createSession('ni'); %creates session object for national 
%instruments daq card
%named for analog input channel

ai.IsContinuous = true; %specifies ai session will run continuously until 
%stopped
ai.Rate = 5000; %sets rate of operation in scans per second 
ai.NotifyWhenDataAvailableExceeds = 25; %controls firing of DataAvailable 
%event.
%when # of scans available > NotifyWhenDataAvailableExceeds,
%DataAvailable event is triggered.
%Rate/NotifyWhenDataAvailableExceeds = number of time DataAvailable event
%automatically fires per second.

%durationInSeconds = 1; % one second of data per trigger. Should this be a
%property of ai?
%ai.SamplesPerTrigger = ai.Rate; % samples per trigger = rate of operation

cha = addAnalogInputChannel(ai,'Dev2',(0:3),'Voltage'); %adds analog input 
%channel to session ai on device Dev1, on specified channel(s), and
%prepared to measure voltage
%addAnalogInputChannel(data acq session,deviceID,channelID,measurementType)
prepare(ai); %prepares ai session for operation, meaning configures and 
%allocates hardware resources and reduces latency associated with startup

dio = daq.createSession('ni'); %creates another session object for national 
%instruments daq card
%named for digital channel, input/output
chd = addDigitalChannel(dio, 'Dev2', {'port0/line0','port0/line1',...
    'port0/line2'},'OutputOnly'); %adds digital channel to session dio on 
%on Dev1 with specified port and single-line combination and channel
%measurement type (output only)
%addDigitalChannel(data acq session,deviceID,channelID,measurementType)
%note: ports have multiple lines; example there could be 8 lines to 1 port
global outputValue %declares global variable for storing digital output
%values
outputValue = zeros(size(dio.Channels)); %initializes as array equivalent
%to the number of channels in session dio
%allocates space for storing output data from each channel
% addTriggerConnection(ai,'external','Dev1/PFI0','StartTrigger'); %adds
% trigger connection from an external device to terminal PFI0 on Dev1 using
% 'StartTrigger' connection type
%addTriggerConnection(s,source,destination,type)
% % %set(ai,'TriggerRepeat',inf); % as soon as buffer filled, trigger again
%sets the 'TriggerRepeat' property to inf
%implements continuous data acquisition
% ai.TriggersPerRun = Inf; %sets the 'TriggersPerRun' property to inf
%trigger can execute an infinite number of times in an operation
lh = addlistener(ai,'DataAvailable',@buffData); %notifies when acquired 
%is available to process
%adds a listener for the DataAvailable event to trigger the buffData
%callback function(a separate function)

try 
    startBackground(ai); %tries starting background operations
catch %if any errors encountered
    stop(ai); %stops the session and any hardware operations
    startBackground(ai); %retries starting background operations
end
    
%plot(timestamp, data)     
% trigger(ai); % begin running and logging
%triggers the instrument to take measurement

% output connections
% dio = digitalio('mcc'); %old functionality, use daq.creatSession or 
%addDigitlChannel instead
% addDigitalChannel(dio, 0, 'out'); % reward line%potential input errors
% addDigitalChannel(dio, 2, 'out'); % trial triggers%potential input errors

end
