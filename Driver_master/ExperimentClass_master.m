classdef ExperimentClass_master < handle %defines handle class
    
    properties
        connection %serial connection
        forward_coeffs = zeros(4,4); %matrix of coefficients for speed model 
        reverse_coeffs = zeros(4,4); %reverse matrix of coefficients for speed model
        save_filename = 'parameters.mat'; %filename for saving parameters (forward_coeffs, reverse_coeffs)
    end
    
    methods
        %% Experiment Constructor
        function obj = ExperimentClass_master(comPort) %comPort is "COM#" from USB serial connection; AKA serial port
            % Intializes Experiment class and opens connection
            obj.connection = serial(comPort); %creates serial port object associated with the serial port
            set(obj.connection,'DataBits',8); %next 4 lines characterize connection
            set(obj.connection,'StopBits',1);
            set(obj.connection,'BaudRate',9600);
            set(obj.connection,'Parity','none');
            
            fopen(obj.connection);
            
            % Confirms serial connection
            SerialInit = 'X';
            while (SerialInit~='A')
                SerialInit=fread(obj.connection,1,'uchar'); %"be ready to receive any incoming"
            end
            if (SerialInit ~= 'A')
                disp('Serial Communication Not Setup');
            elseif (SerialInit=='A')
                disp('Serial Read')
            end
            
            fprintf(obj.connection,'%c','A'); %MATLAB sends out 'A'
            %equivalent of typing 'A' into serial monitor from Arduino side
            
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
        
        function output = readSerial(obj,type)
            output = fscanf(obj.connection,type);
        end
        
        %% LINEAR OSCILLATION - robot movement function
        function linearOscillate(obj,x0,y0,x1,y1,speed,repetitions)
            % Moves from point (x0,y0) to (x1,y1). Speed is characterized by the
            % pulse-width modulation of the signals set to the stepper motor. Movement
            % will oscillate the number of times as repetitions. Resolution represents
            % the step size for drawing of a pathway. Movement at the 10% edges are
            % slowed down.
            fprintf(obj.connection,('linearOscillate:%d:%d:%d:%d:%d:%d'),...
                [x0,y0,x1,y1,speed,repetitions]);
            checkForMovementEnd(obj, 'Linear Oscillate Trial');
        end
        
        %% CALIBRATION - robot movement function
        function calibrate(obj)
            % Returns target to xMin and yMin at the bottom-left corner
            fprintf(obj.connection,'calibrate:');
            checkForMovementEnd(obj, 'Calibrate');
        end
        
        %% Move To - robot movement command
        function moveTo(obj,x,y,hold)
            %count = 0; %to count number of times display while loop runs
            % Moves target to (x,y) and holds for designated milliseconds
            fprintf(obj.connection,('moveTo:%f:%f:%d'),[x,y,hold]);
            checkForMovementEnd(obj, 'Linear Move Trial');
        end
        
        %% Arc - robot movement command
        function arcMove(obj,diameter,angInit,angFinal,speed,numLines)
            % Moves target in an arc specified by radius and initial and final
            % angles
            fprintf(obj.connection,('arcMove:%d:%d:%d:%d:%d'),...
                [diameter,angInit,angFinal,speed,numLines]);
            
            %IN DEVELOPMENT
            %angle inputs range from 90 to -90 degrees
            %max number for numLines is 36
%             dx = zeros(1,numLines); dy = zeros(1,numLines);
%             Delays = zeros(1,numLines); %preallocating
%             microsteps = 16;
%             motor_radius = 0.65; %cm
%             arcRes = (numLines - 1) / 3;
%             speed = (200 * speed) / (1.2 * pi);
%             R = diameter / (4 * pi * motor_radius) * 200 * microsteps;
%             
%             angInit_rad = (pi / 180) * (-angInit + 90); %for init and final, convert inputs to range from 0 to 180 degrees
%             angFinal_rad = (pi / 180) * (-angFinal + 90); %then convert to radians
%             angInit_res = angInit_rad * arcRes; %scale by angles by arcRes
%             angFinal_res = angFinal_rad * arcRes;
%             
%             count = 1;
%             for i = angInit_res:(angFinal_res/numLines):angFinal_res
%                 dx(count) = -R / arcRes * sin(i / arcRes);
%                 dy(count) = R / arcRes * cos(i / arcRes);
%                 angle = atan(dy(count) / dx(count) * 180/pi);
%                 Delays(count) = speedToDelay(obj, speed, angle);
%                 count = count + 1;
%             end
%             %testing
%             
%             waitSignal = check(obj) % should receive "ReadyToReceiveDelays"
%             sendInfo(obj, Delays);
%             waitSignal = check(obj) % should receive "DelaysReceived"
%             sendInfo(obj, dx);
%             waitSignal = check(obj) % should receive "dxReceived"
%             sendInfo(obj, dy);
%             waitSignal = check(obj) % should receive "dyReceived"
            if (diameter > 35)  
                waitsignal = check(obj)
            else
            checkForMovementEnd(obj, 'Arc Movement/Smooth Pursuit Trial');
            end 
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
                [delayi,delayf,ddelay,angleTrials]);
            % while Beginning is being sent from Arduino, print given message
            %             while(strcmp(fscanf(obj.connection,'%s'),'Beginning')==1)
            %                 disp('Speed Experiment Trials');
            %             end
            
            % 1st read from Arduino: ddistance
            ddistance = fscanf(obj.connection,'%d')
            %finalDistance = ddistance*angleTrials; % an unused variable
            delayTrials = floor((delayf-delayi)/ddelay + 1);
            
            % Preallocate arrays
            % Every column will be a different speed
            time = zeros(angleTrials,delayTrials);
            delays = delayi:ddelay:delayf;
            x = zeros(angleTrials,delayTrials);
            y = zeros(angleTrials,delayTrials);
            delayCount = 0;
            
            % Keep doing calculations until waitSignal=Done and then break;
            while(1)
                % 2nd and until 'Done' read from Arduino: status of waitSignal
                waitSignal = fscanf(obj.connection,'%s')
                if (strcmp(waitSignal,'Done')==1)
                    break;
                elseif (strcmp(waitSignal,'Sending')==1)
                    % When waitSignal=Sending, prepare to read data
                    for i=1:angleTrials
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
            %speedArray_cm_s = (sqrt(x.^2+y.^2)./(time./1000)).*(3.76991./200); %speedArray converted to cm/s
            save('speed_step','speedArray_steps_s');
            %save('speed_cm','speedArray_cm_s');
            
            % Convert x and y distance to angle in degrees
            angles = atan(y(1:angleTrials,1)./x(1:angleTrials,1))*180/pi;
            save('angles','angles');
            
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

