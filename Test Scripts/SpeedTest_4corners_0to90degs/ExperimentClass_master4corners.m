classdef ExperimentClass_master4corners < handle %define handle class
    
    properties %define properties of the handle class
        connection %serial connection
        forward_coeffs = zeros(4,4); %matrix of coefficients for speed model, speedToDelay
        reverse_coeffs = zeros(4,4); %reverse matrix of coefficients for speed model, delayToSpeed 
        save_filename = 'parameters.mat'; %variable for filename for saving parameters (forward_coeffs, reverse_coeffs)
    end
    
    methods %define methods of the handle class (functions to use)
        %% Experiment Constructor
        % constructor method to create an instance of the class
        % ExperimentClass_master4corners
        function obj = ExperimentClass_master4corners(serialPort) %comPort is "COM#" from USB serial connection; AKA serial port
            obj.connection = serial(serialPort); %creates serial port object associated with the serial port
            set(obj.connection,'DataBits',8); %next 4 lines characterize communication port connection
            set(obj.connection,'StopBits',1);
            set(obj.connection,'BaudRate',9600);
            set(obj.connection,'Parity','none');
            
            fopen(obj.connection); %start serial connection/open serial port object
            
            % Confirm serial connection
            % equivalent to initialize function in Driver_master.ino
            % string 'A' sent and received  
            SerialInit = 'X'; %store string X in variable SerialInit
            while (SerialInit~='A') %while SerialInit not equal to string A
                SerialInit=fread(obj.connection,1,'uchar'); %read data from serial port
            end
            if (SerialInit ~= 'A') %if something other than A received from Arduino
                disp('Serial Communication Not Setup'); %display message
            elseif (SerialInit=='A') %if A received from Arduino
                disp('Serial Read') %display message
            end
            
            fprintf(obj.connection,'%c','A'); %MATLAB sends out 'A'
            %equivalent of typing 'A' into serial monitor on Arduino side
            
            flushinput(obj.connection); %removes data from input buffer associated with serial port
            
            % Save parameters (forward_coeffs, reverse_coeffs) that will be sent from MATLAB
            % to Arduino at start of each experiment
            parameters = load(obj.save_filename);
            obj.forward_coeffs = parameters.forward_coeffs;
            obj.reverse_coeffs = parameters.reverse_coeffs;
            forward_coeffs = obj.forward_coeffs;
            reverse_coeffs = obj.reverse_coeffs;
            
            % Communicate with Arduino and send speed model coefficients
%             waitSignal = check(obj) %should receive and print in command window "ReadyToReceiveCoeffs"
%             sendInfo(obj, forward_coeffs);
%             waitSignal = check(obj) %should receive "ForwardCoeffsReceived"
%             sendInfo(obj, reverse_coeffs);
%             waitSignal = check(obj) %should receive "ReverseCoeffsReceived"
%             
             waitSignal = check(obj) %read from Arduino; should receive "Ready"

        end
        
        %% Close Serial Connection
        function endSerial(obj)
            fclose(obj.connection);
        end
        
        %% Calculate Speed Model
        % calculates Euclidean speed for various angles at specified delays
        % Euclidean speeds used to generate models for converting from
        % delay to speed and vice versa
        % currently, the quickest obtainable speed for linear movement is a
        % delay of 15 microseconds
        function obj = speedModelFit(...
                obj,delayi,delayf,ddelay,angleTrials)
            
            % Communicate with Arduino all the variables
            fprintf(obj.connection,('speedModelFit:%d:%d:%d:%d'),...
                [delayi,delayf,ddelay,angleTrials]);%send string in this format with colon delimiter to Arduino
            % while Beginning is being sent from Arduino, print given message
            %             while(strcmp(fscanf(obj.connection,'%s'),'Beginning')==1)
            %                 disp('Speed Experiment Trials');
            %             end
            
            % 1st read from Arduino: ddistance
            ddistance = fscanf(obj.connection,'%d')
            %finalDistance = ddistance*angleTrials; % an unused variable
            delayTrials = floor((delayf-delayi)/ddelay + 1);
            totalAngles = (angleTrials * 2) - 1;
            % Preallocate arrays
            % Every column will be a different speed
            time = zeros(totalAngles,delayTrials);
            delays = delayi:ddelay:delayf;
            x = zeros(totalAngles,delayTrials);
            y = zeros(totalAngles,delayTrials);
            delayCount = 0;
            
            % Keep doing calculations until waitSignal=Done and then break;
            while(1)
                % 2nd and until 'Done' read from Arduino: status of waitSignal
                waitSignal = fscanf(obj.connection,'%s')
                if (strcmp(waitSignal,'Done')==1)
                    break;
                elseif (strcmp(waitSignal,'Sending')==1)
                    % When waitSignal=Sending, prepare to read data
                    for i=1:totalAngles
                        timeRead = fscanf(obj.connection,'%d');
                        time(i,delayCount+1) = timeRead;
                        x(i,delayCount+1) = fscanf(obj.connection,'%d');
                        y(i,delayCount+1) = fscanf(obj.connection,'%d');
                    end
                    delayCount = delayCount+1
                end
            end
            
            % compute Euclidean speed
            speedArray_steps_s = (sqrt(x.^2+y.^2)./(time./1000)); %in steps/second
            %conversion factor is pi*1.2 cm (3.769911 cm) = 200 steps
            speedArray_cm_s = (sqrt(x.^2+y.^2)./(time./1000)).*((2.*pi.*0.65)./200); %speedArray converted to cm/s
            save('speed_step','speedArray_steps_s');
            save('speed_cm','speedArray_cm_s');
            
            % Convert x and y distance to angle in degrees
            angles = atan(y(1:totalAngles,1)./x(1:totalAngles,1))*180/pi;
            save('angles','angles');
            save('delayTrials','delayTrials');
            
            %% Finding model of delay to speed
            % For each delay, finds the coefficients of a
            % 2-term exponential model of angle vs measured speed
            % Requires at least 10 trials each to generate a fit
            coeffs_angles = zeros(length(delays),4);
            for i = 1:length(delays)
                f = fit(angles,speedArray_steps_s(:,i),'exp2');
                coeffs_angles(i,:) = [f.a,f.b,f.c,f.d]; % save coefficients
            end
            
            % Models the columns in coeffs_angles with a 2-term exponential
            % with respect to delays
            forward_coeffs = zeros(4,4);
            for i = 1:4
                f = fit(transpose(delays),coeffs_angles(:,i),'exp2');
                forward_coeffs(i,:) = [f.a,f.b,f.c,f.d];
            end
            
            %% Finding model of speed to delay
            % For each angle, finds the coefficients of a
            % 2-term exponential model of measured speed vs delay
            % Requires at least 10 trials each to generate a fit
            coeffs_delays = zeros(length(angles),4);
            for i = 1:numel(angles)
                f = fit(transpose(speedArray_steps_s(i,:)),transpose(delays),'exp2');
                coeffs_delays(i,:) = [f.a,f.b,f.c,f.d];
            end
            
            % Models the columns in coeffs_delays as a 3rd degree
            % polynomial with respect to angles
            reverse_coeffs = zeros(4,4);
            for i = 1:4
                f = fit(angles,coeffs_delays(:,i),'poly3');
                reverse_coeffs(i,:) = [f.p1,f.p2,f.p3,f.p4];
            end
            
            % Save coefficients in parameters.mat
            obj.forward_coeffs = forward_coeffs;
            obj.reverse_coeffs = reverse_coeffs;
            save(obj.save_filename,'forward_coeffs','reverse_coeffs');
        end
        %% Calculating a given delay and converting to speed
        % coeff_array is a 4x4 array - rows and columns both representing exp2
        function [speed] = delayToSpeed(obj,delay,angle)
            complex_coeffs = zeros(size(obj.forward_coeffs));
            for i = 1:length(obj.forward_coeffs(:,1))
                complex_coeffs(i) = obj.exp2(obj.forward_coeffs(i,:),delay);
            end
            speed = obj.exp2(complex_coeffs,angle);
        end
        
        %% Calculating input speed to a delay sent to Arduino
        % coeff_array is a 4x4 array - rows representing exp2, columns representing
        % poly3
        function [delay] = speedToDelay(obj,speed,angle)
            complex_coeffs = zeros(size(obj.reverse_coeffs));
            for i = 1:length(obj.reverse_coeffs(:,1))
                complex_coeffs(i) = obj.poly3(obj.reverse_coeffs(i,:),angle);
            end
            delay = obj.exp2(complex_coeffs,speed);
        end
        
        %% 2nd Degree Polynomial
        % not currently used
        % not a good model for speed to delay conversion
        function [output] = poly2(obj,coeffs,x)
            output = coeffs(1).*x.^2 + coeffs(2).*x + coeffs(3);
        end
        
        %% 3rd Degree Polynomial
        function [output] = poly3(obj,coeffs,x)
            output = coeffs(1).*x.^3 + coeffs(2).*x.^2 + coeffs(3).*x + coeffs(4);
        end
        
        %% 2-term Fourier
        % not currently used
        % was tested as a model for reverse_coeffs
        % slightly less accurate than 3rd degree polynommial
        function [output] = fourier2(obj,coeffs,x)
            output = coeffs(1) + coeffs(2).*cos(x.*coeffs(6)) +...
                coeffs(3).*sin(x.*coeffs(6)) +...
                coeffs(4).*cos(2.*x.*coeffs(6)) +...
                coeffs(5).*sin(2.*x.*coeffs(6));
        end
        
        %% Two-Term Exponential Function
        function [output] = exp2(obj,coeffs,x)
            output = coeffs(1).*exp(coeffs(2).*x) + coeffs(3).*exp(coeffs(4).*x);
        end
        
        %% sendInfo function
        % takes in matrix of coeffcients
        % converts matrix to a string that with : delimiter
        % sends string to Arduino
        % receives string back from Arduino confirming coefficients
        % were received and parsed       
        function sendInfo(obj, coeffs)
            str = inputname(2);
            strList = sprintf(':%d', coeffs);
            strToSend = [str strList]
            fprintf(obj.connection, strToSend);
        end
        
        %% waitSignal - communication function  
        % do not suppress "waitSignal = check(obj)" line if you want what's
        % received to print in MATLAB's command window
        %
        % reads info in serial buffer
        % contiues reading if nothing received
        % if something is received
        % prints in command window
        function waitSignal = check(obj)
            data = ''; % "data" variable starts out empty
            while(1)
                data = fscanf(obj.connection, '%s'); % reads and stores data from serial buffer 
                if isempty(data) == 1 % if nothing is read
                    data = fscanf(obj.connection, '%s');% continue reading
                    %1
                elseif isempty(data) == 0 % if something is received
                    waitSignal = data; % print it; it will likely be a string (message w/ no spaces)
                    break;
                end
            end
        end
        
        %% checkForMovementEnd - communication function
        % similar to waitSignal function
        % waits for message from Arduino that an LED/robot has finished
        % then prints it
        function checkForMovementEnd(obj, message)
            endSignal = '';
            while(1)
                endSignal = fscanf(obj.connection, '%s');
                if strcmp(endSignal, 'Done') ~= 1
                else
                    disp(message);
                    break;
                end
            end
        end    
    end  
end

