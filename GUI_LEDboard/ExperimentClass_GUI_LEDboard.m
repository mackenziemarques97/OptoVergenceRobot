classdef ExperimentClass_GUI_LEDboard < handle %define handle class
        
    properties %define properties of the handle class
        connection %serial connection
    end
    
    methods %define methods of the handle class (functions to use)
        %% Experiment Constructor
        % constructor method to create an instance of the class
        % ExperimentClass_master
        
        %comPort is "COM#" from USB serial connection; AKA serial port
        function obj = ExperimentClass_GUI_LEDboard(serialPort) 
            %creates serial port object associated with the serial port
            obj.connection = serial(serialPort); 
            %next 4 lines characterize communication port connection
            set(obj.connection,'DataBits',8); 
            set(obj.connection,'StopBits',1);
            set(obj.connection,'BaudRate',9600);
            set(obj.connection,'Parity','none');
            set(obj.connection,'Timeout',30);
            
            %start serial connection/open serial port object
            fopen(obj.connection);
            
            % Confirm serial connection
            % equivalent to initialize function in Driver_master.ino
            % string 'A' sent and received  
            SerialInit = 'X'; %store string X in variable SerialInit
            while (SerialInit~='A') %while SerialInit not equal to string A
                %read data from serial port
                SerialInit=fread(obj.connection,1,'uchar'); 
            end
            %if something other than A received from Arduino
            if (SerialInit ~= 'A') 
                disp('Serial Communication Not Setup'); %display message
            elseif (SerialInit=='A') %if A received from Arduino
                disp('Serial Read') %display message
            end
            
            fprintf(obj.connection,'%c','A'); %MATLAB sends out 'A'
            %equivalent of typing 'A' into serial monitor on Arduino side
            %removes data from input buffer associated with serial port
            flushinput(obj.connection); 
            
            waitSignal = check(obj)       
        end
        
        %% sendPhaseParams 
        % sends LED parameters from MATLAB to Arduino
        function sendPhaseParams(obj,dir,color,deg,timeOn)
            str1 = sprintf('sendPhaseParams:%s:%s:',[dir,color]);
            str2 = sprintf('%d:%d:',[deg,timeOn]);
            sendInfo = [str1 str2];       
            fprintf(obj.connection, sendInfo); 
            
            waitSignal = check(obj)       
        end
        
        %% showLEDs
        % displays any changes of LED parameters since last call
        function showLEDs(obj)            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,'showLEDs:'); 
            
            waitSignal = check(obj)       
        end
        
        %% clearLEDs
        % clear all LEDs ~ set them to black
        function clearLEDs(obj)            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,'clearLEDs:'); 
            
            waitSignal = check(obj)       
        end
        
        %% Close Serial Connection
        function endSerial(obj)
            fclose(obj.connection); %close connection
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
                data = fscanf(obj.connection, '%s');  
                if isempty(data) == 1 % if nothing is read
                    data = fscanf(obj.connection, '%s');% continue reading
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
