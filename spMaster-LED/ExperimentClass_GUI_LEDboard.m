classdef ExperimentClass_GUI_LEDboard < handle %define handle class
        
    properties %define properties of the handle class
        connection %serial connection
    end
    
    methods %define methods of the handle class (functions to use)
        %% Experiment Constructor
        % constructor method to create an instance of the class
        % ExperimentClass_master
        
        %comPort is "COM#" from USB serial connection; AKA serial port
        function obj = ExperimentClass_GUI_LEDboard(COM) 
            %creates serial port object associated with the serial port
            %set properties
            %open connection
            startTalk = tic;
            obj.connection = serialport(COM,9600,"DataBits",8,"Timeout",60); 
            
            % Confirm serial connection
            % equivalent to initialize function in Driver_master.ino
            % string 'A' sent and received  
            SerialInit = 'X'; %store string X in variable SerialInit
            while (SerialInit~='A') %while SerialInit not equal to string A
                %read data from serial port
                SerialInit=read(obj.connection,1,'char'); 
            end
            %if something other than A received from Arduino
            if (SerialInit ~= 'A') 
                disp('Serial Communication Not Setup'); %display message
            elseif (SerialInit=='A') %if A received from Arduino
                disp('Serial Read') %display message
            end
            
            write(obj.connection,'A','char'); %MATLAB sends out 'A'
            %equivalent of typing 'A' into serial monitor on Arduino side
            %removes data from input buffer associated with serial port
            flush(obj.connection); 
            
            waitSignal = check(obj)
            
            %setupTime = toc(startTalk)
            
        end
        
        %% sendPhaseParams 
        % sends LED parameters from MATLAB to Arduino
        function sendPhaseParams(obj,dir,color,deg,timeOn)
            str1 = sprintf('sendPhaseParams:%s:%s:',[dir,color]);
            str2 = sprintf('%d:%d:',[deg,timeOn]);
            sendInfo = [str1 str2];       
            writeline(obj.connection, sendInfo); 
            waitSignal = check(obj)
        end
        
        %% turnOnLED
        % displays any changes of LED parameters since last call
        function turnOnLED(obj)  
            %send string in this format with colon delimiter to Arduino
            writeline(obj.connection,'turnOnLED:'); 
            waitSignal = check(obj)
        end
        
        %% turnOffLED
        function turnOffLED(obj)  
            %send string in this format with colon delimiter to Arduino
            writeline(obj.connection,'turnOffLED:'); 
            waitSignal = check(obj)
        end
        
        %% clearLEDs
        % clear all LEDs ~ set them to black
        function clearLEDs(obj)            
            %send string in this format with colon delimiter to Arduino
            writeline(obj.connection,'clearLEDs:');       
            waitSignal = check(obj)
        end
        
        %% Close Serial Connection
        function endSerial(obj)
            delete(obj.connection); %close connection
        end
        
        %% waitSignal - communication function  
        % do not suppress "waitSignal = check(obj)" line if you want what's
        % received to print in MATLAB's command window
        %
        % reads info in serial buffer
        % continues reading if nothing received
        % if something is received
        % prints in command window
        function waitSignal = check(obj)
            data = ''; % "data" variable starts out empty
            while(1)
                % reads and stores data from serial buffer
                data = readline(obj.connection);  
                if isempty(data) == 1 % if nothing is read
                    data = readline(obj.connection);% continue reading
                    %1
                elseif isempty(data) == 0 % if something is received
                    % print it
                    % it will be a string (message w/ no spaces)
                    waitSignal = data; 
                    break;
                end
            end
        end
    end
end

