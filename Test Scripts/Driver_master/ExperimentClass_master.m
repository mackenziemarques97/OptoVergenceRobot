classdef ExperimentClass_master < handle %define handle class
    
    properties %define properties of the handle class
        connection %serial connection
        %matrix of coefficients for speed model, delayToSpeed
        forward_coeffs = zeros(4,4);
        %reverse matrix of coefficients for speed model, speedToDelay
        reverse_coeffs = zeros(4,4); 
        %variable for filename for saving parameters
        %forward_coeffs & reverse_coeffs
        save_filename = 'parameters.mat'; 
    end
    
    methods %define methods of the handle class (functions to use)
        %% Experiment Constructor
        % constructor method to create an instance of the class
        % ExperimentClass_master
        
        %comPort is "COM#" from USB serial connection; AKA serial port
        function obj = ExperimentClass_master(serialPort) 
            %creates serial port object associated with the serial port
            obj.connection = serial(serialPort); 
            %next 4 lines characterize communication port connection
            set(obj.connection,'DataBits',8); 
            set(obj.connection,'StopBits',1);
            set(obj.connection,'BaudRate',9600);
            set(obj.connection,'Parity','none');
            set(obj.connection,'Timeout',60);
            
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
            
            % Save parameters (forward_coeffs, reverse_coeffs) that will be
            % sent from MATLAB to Arduino at start of each experiment
            parameters = load(obj.save_filename);
            obj.forward_coeffs = parameters.forward_coeffs;
            obj.reverse_coeffs = parameters.reverse_coeffs;
            forward_coeffs = obj.forward_coeffs;
            reverse_coeffs = obj.reverse_coeffs;
            
            % Communicate with Arduino and send speed model coefficients
            %should receive and print in command window "ReadyToReceiveCoeffs"
%             waitSignal = check(obj) 
%             sendInfo(obj, forward_coeffs);
%             %should receive "ForwardCoeffsReceived"
%             waitSignal = check(obj) 
%             sendInfo(obj, reverse_coeffs);
%             %should receive "ReverseCoeffsReceived"
%             waitSignal = check(obj) 
%             %read from Arduino; should receive "Ready"
            waitSignal = check(obj) 
        end
        
        
        %% ONELED 
        function oneLED(obj,dir,col,deg,timeOn)   
            str1 = sprintf('oneLED:%s:%s:',[dir,col]);
            str2 = sprintf('%d:%d', [deg, timeOn]);
            sendoneled = [str1 str2];
            
            fprintf(obj.connection,sendoneled); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'OneLED Trial'); 
        end
        
        %% SACCADE
        function saccade(obj,switchcase,dir1,col1,deg1,timeOn1,dir2,col2,deg2,timeOn2)
            str1 = sprintf('saccade:%d:',switchcase);
            str2 = sprintf('%s:%s:',[dir1,col1]);
            str3 = sprintf('%d:%d:',[deg1,timeOn1]);
            str4 = sprintf('%s:%s:',[dir2,col2]);
            str5 = sprintf('%d:%d',[deg2,timeOn2]);
            sendsaccade = [str1 str2 str3 str4 str5];
        
            fprintf(obj.connection,sendsaccade); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'Saccade Trial'); 
        end
        
        %%  %% SMOOTH PURSUIT
        function smoothPursuit(obj,dir,col,degInit,degFinal)
            str1 = sprintf('smoothPursuit:%s:%s:',[dir,col]);
            str2 = sprintf('%d:%d', [degInit,degFinal]);
            sendsmoothpursuit = [str1 str2];

            fprintf(obj.connection,sendsmoothpursuit); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'Smooth Pursuit Trial'); 
        end
                
        %% CALIBRATION - robot movement method
        function calibrate(obj)
            % Returns target to xMin and yMin at the bottom-left corner
            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,'calibrate:'); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'Calibrate'); 
        end
        
        %% Move To - robot movement method
        function moveTo(obj,x,y,hold)
            % Moves target to (x,y) and holds for designated milliseconds
            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,('moveTo:%f:%f:%d'),[x,y,hold]); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'Linear Move Trial'); 
        end
        
        %% LINEAR OSCILLATION - robot movement method
        function linearOscillate(obj,x0,y0,x1,y1,speed,repetitions)
            % Moves from point (x0,y0) to (x1,y1). Speed is characterized 
            % by the pulse-width modulation of the signals set to the 
            % stepper motor. Movement will oscillate the number of times 
            % as repetitions. Resolution represents the step size for
            % drawing of a pathway. Movement at the 10% edges are
            % slowed down.
            
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,('linearOscillate:%d:%d:%d:%d:%d:%d'),...
                [x0,y0,x1,y1,speed,repetitions]); 
            %check that "Done" is received at end of movement
            checkForActionEnd(obj, 'Linear Oscillate Trial'); 
        end
        
        %% Arc - robot movement method
        function arcMove(obj,diameter,angInit,angFinal,speed,numLines)
            % Moves target in an arc specified by radius and initial and 
            % final angles
            
            %send strings in this format with colon delimiter to Arduino
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
%             % should receive "ReadyToReceiveDelays"
%             waitSignal = check(obj) 
%             sendInfo(obj, Delays);
%             % should receive "DelaysReceived"
%             waitSignal = check(obj) 
%             sendInfo(obj, dx);
%             % should receive "dxReceived"
%             waitSignal = check(obj) 
%             sendInfo(obj, dy);
%             % should receive "dyReceived"
%             waitSignal = check(obj) 
            
              %check that "Done" is received at end of movement
              checkForActionEnd(obj,...
              'Arc Movement/Smooth Pursuit Trial');  
        end
        
        %% Close Serial Connection
        function endSerial(obj)
            fclose(obj.connection); %close connection
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
            %send string in this format with colon delimiter to Arduino
            fprintf(obj.connection,('speedModelFit:%d:%d:%d:%d'),...
                [delayi,delayf,ddelay,angleTrials]);
            
            % 1st read from Arduino: ddistance; read from Arduino and
            % printed
            ddistance = fscanf(obj.connection,'%d')
            %finalDistance = ddistance*angleTrials; % an unused variable
            delayTrials = floor((delayf-delayi)/ddelay + 1);
            
            % Preallocate arrays
            % rows contain data for same angle/each row represents an
            % angle
            % columns contain data for same delay/each column represents a
            % delay
            delays = delayi:ddelay:delayf;
            time = zeros(angleTrials,delayTrials);
            x = zeros(angleTrials,delayTrials);
            y = zeros(angleTrials,delayTrials);
            delayCount = 0;
            
            % Keep doing calculations until waitSignal=Done and then break;
            while(1)
                % 2nd read from read from Arduino: status of waitSignal
                waitSignal = fscanf(obj.connection,'%s')
                %if waitSignal reads 'Done'
                if (strcmp(waitSignal,'Done')==1)
                    %then break
                    break;
                %if waitSignal reads 'Sending'
                elseif (strcmp(waitSignal,'Sending')==1)
                    %prepare to read data and allocate to designated arrays
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
            %in steps/second
            speedArray_steps_s = (sqrt(x.^2+y.^2)./(time./1000)); 
            %conversion factor is 1 revolution = 2*pi*0.65 cm = 200 steps
            %speedArray converted to cm/s
            speedArray_cm_s = speedArray_steps_s.*((2*pi*0.65)./200); 
            save('speed_step','speedArray_steps_s');
            save('speed_cm','speedArray_cm_s');
            
            % Convert x and y distance to angle in degrees
            angles = atan(y(1:angleTrials,1)./x(1:angleTrials,1))*180/pi;
            save('angles','angles');
            
            %% Finding model of speed to delay
            % The intention is to be able to input a speed (in cm/s)
            % into a function that will output the necessary delay (in us),
            % given a certain angle, that would be required to achieve that
            % speed. The function is a model of delay vs. angle and speed. 
            
            % For each angle, finds the coefficients of a
            % 2-term exponential model of measured speed vs delay
            % Requires at least 10 trials each to generate a fit
            
            % OUTER FUNCTION
            % inputs speed
            % outputs delay
            
            % for delays, initialize array to have 4 coefficients for each
            % angle
            % each row of coeffs_delays represents an angle
            % each column of coeffs_delays represents a coefficient 
            % of the function
            % 4 coefficients necessary to define 2-term exponential
            coeffs_delays = zeros(length(angles),4);
            %for each angle
            for i = 1:numel(angles)
                %fit curve of speed in steps/sec vs. delays with a 
                %2 term exponential
                f = fit(transpose(speedArray_steps_s(i,:)),...
                    transpose(delays),'exp2');
                %save coefficients at each angle
                %4 coeffs for each set of speed vs. delay
                coeffs_delays(i,:) = [f.a,f.b,f.c,f.d];
            end
            
            % INNER FUNCTION
            % inputs angles
            % outputs coefficients for outer function
            
            % Models the columns in coeffs_delays as a 3rd degree
            % polynomial with respect to angles.
            % The columns represent the coefficients of each term in the
            % 2-term exp. 
            reverse_coeffs = zeros(4,4);
            %for each column of coeffs_delays, which corresponds to
            %one of the coefficients of a 2-term exponential
            for i = 1:4
                %fit the curve of coeffs_delays vs. angles as a 3rd degree
                %polynomial
                f = fit(angles,coeffs_delays(:,i),'poly3');
                %save coefficients from fit of inner coefficients
                %4 outer coeffecicents
                reverse_coeffs(i,:) = [f.p1,f.p2,f.p3,f.p4];
            end
            
            %% Finding model of delay to speed
            % The intention is to be able to input a delay/pulse width 
            % in us into a function that outputs the necessary speed in 
            % cm/s that would require that delay. The function is a
            % model of speeds vs. angles and delays. This approach is used
            % to check speed to delay model, which will be directly
            % implemented in the Arduino code.
            
            % For each delay, finds the coefficients of a
            % 2-term exponential model of angle vs measured speed
            % Requires at least 10 trials each to generate a fit
            
            % OUTER FUNCTION
            % inputs angle
            % outputs speed
            
            %for angles, initialize array to have 4 coefficients for 
            %each delay
            %4 coefficients necessary to define 2-term exponential
            coeffs_angles = zeros(length(delays),4); 
            %for each delay
            for i = 1:length(delays)
                %fit curve of speed in steps/sec vs. angles with a 
                %2 term exponential
                f = fit(angles,speedArray_steps_s(:,i),'exp2'); 
                %save coefficients at each delay
                %4 coeffs for each set of speed vs. angles
                coeffs_angles(i,:) = [f.a,f.b,f.c,f.d]; 
            end
            
            % INNER FUNCTION
            % inputs delays
            % outputs coefficients for outer function
            
            % Models the columns in coeffs_angles with a 2-term exponential
            % with respect to delays
            forward_coeffs = zeros(4,4);
            %for each column of coeffs_angles, which corresponds to
            %one of the coefficients of a 2-term exponential
            for i = 1:4
                %fit the curve of coeffs_angles vs. delays as a 2-term
                %exponential
                f = fit(transpose(delays),coeffs_angles(:,i),'exp2');
                %save coefficients from fit of inner coefficients
                %4 coeffs for each coefficient
                forward_coeffs(i,:) = [f.a,f.b,f.c,f.d];
            end
            
            % Save coefficients in parameters.mat
            obj.forward_coeffs = forward_coeffs; %for delayToSpeed
            obj.reverse_coeffs = reverse_coeffs; %fpr speedToDelay
            save(obj.save_filename,'forward_coeffs','reverse_coeffs');
        end
        %% Calculating a delay given speed and angle
        % reverse_coeffs is a 4x4 array 
        % input speed & angle
        % output delay
        % inner function uses poly3
        % outer function uses exp2
        function [delay] = speedToDelay(obj,speed,angle)
            %initialize matrix that is 4x1, for coeffs of outer func
            complex_coeffs = zeros(length(obj.reverse_coeffs(1,:)),1);
            %for i = 1:4 (length of the first row of forward_coeffs)
            for i = 1:length(obj.reverse_coeffs(1,:))
                %calculate outer func coeffs using reverse_coeffs
                %as coeffs for poly3 and the angle as an input
                complex_coeffs(i) = obj.poly3(obj.reverse_coeffs(i,:),...
                    angle);
            end
            %use the outer func coeffs and the speed as an input to
            %calculate the delay
            delay = obj.exp2(complex_coeffs,speed);
        end
        
        %% Calculating a speed given delay and angle
        % forward_coeffs is a 4x4 array 
        % input delay & angle
        % output speed
        % inner function uses exp2
        % outer function uses exp2
        function [speed] = delayToSpeed(obj,delay,angle)
            %initialize matrix that is 4x1, for coeffs of outer func
            complex_coeffs = zeros(length(obj.forward_coeffs(1,:)),1);
            %for i = 1:4 (length of the first row of forward_coeffs)
            for i = 1:length(obj.forward_coeffs(1,:))
                %calculate outer func coeffs using foward_coeffs
                %as coeffs for exp2 and the delay as an input
                complex_coeffs(i) = obj.exp2(obj.forward_coeffs(i,:),...
                    delay);
            end
            %use the outer func coeffs and the angle as an input to
            %calculate the speed
            speed = obj.exp2(complex_coeffs,angle);
        end
        
        %% 3rd Degree Polynomial
        function [output] = poly3(obj,coeffs,x)
            output = coeffs(1).*x.^3 + coeffs(2).*x.^2 +...
                coeffs(3).*x + coeffs(4);
        end
        
        %% Two-Term Exponential Function
        function [output] = exp2(obj,coeffs,x)
            output = coeffs(1).*exp(coeffs(2).*x) +...
                coeffs(3).*exp(coeffs(4).*x);
        end
        
        %% sendInfo function
        % takes in matrix of coeffcients
        % converts matrix to a string that with : delimiter
        % sends string to Arduino
        % receives string back from Arduino confirming coefficients
        % were received and parsed       
        function sendInfo(obj, coeffs)
            str = inputname(2);
            for i = 1:length(coeffs(1,:))
               strList = sprintf(':%d', coeffs(i,:));
               strToSend = [str strList];
               str = strToSend;
            end
            %strToSend %display string being sent in command window
            fprintf(obj.connection, strToSend);
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
        
        %% checkForActionEnd - communication function
        % similar to waitSignal function
        % waits for message from Arduino that an LED/robot has finished
        % then prints it
        function checkForActionEnd(obj, message)
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

