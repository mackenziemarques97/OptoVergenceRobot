%% speedToDelay matrix calculated in MATLAB and sent to Arduino
save_filename = 'parameters.mat';
parameters = load(save_filename);
reverse_coeffs = parameters.reverse_coeffs;

diameter = 30;
angInit = 90;
angFinal = -90;
speed = 900;
numLines = 36; %will store numLines+1 delays, first one doesn't count

%testing
%angle inputs range from 90 to -90 degrees
dx = zeros(1,numLines); dy = zeros(1,numLines); 
angles = zeros(1,numLines); Delays = zeros(1,numLines); %preallocating
microsteps = 16;
motor_radius = 0.65; %cm
arcRes = (numLines - 1) / 3;
R = diameter / (4 * pi * motor_radius) * 200 * microsteps;

angInit_rad = (pi / 180) * (-angInit + 90); %for init and final, convert inputs to range from 0 to 180 degrees
angFinal_rad = (pi / 180) * (-angFinal + 90); %then convert to radians
angInit_res = angInit_rad * arcRes; %scale by angles by arcRes
angFinal_res = angFinal_rad * arcRes;

count = 1;
for i = angInit_res:(angFinal_res/numLines):angFinal_res
    dx(count) = -R / arcRes * sin(i / arcRes);
    dy(count) = R / arcRes * cos(i / arcRes);
    angles(count) = atan(dy(count) / dx(count) * 180/pi);
    Delays(count) = speedToDelay(reverse_coeffs, speed, angles(count));
    count = count + 1;
end

        %% Calculating input speed to a delay sent to Arduino
        % coeff_array is a 4x4 array - rows representing exp2, columns representing
        % poly3
        function [delay] = speedToDelay(reverse_coeffs,speed,angle)
            complex_coeffs = zeros(size(reverse_coeffs));
            for i = 1:length(reverse_coeffs(:,1))
                complex_coeffs(i) = poly3(reverse_coeffs(i,:),angle);
            end
            delay = exp2(complex_coeffs,speed);
        end
        
                %% 3rd Degree Polynomial
        function [output] = poly3(coeffs,x)
            output = coeffs(1).*x.^3 + coeffs(2).*x.^2 + coeffs(3).*x + coeffs(4);
        end 
        
                %% Two-Term Exponential Function
        function [output] = exp2(coeffs,x)
            output = coeffs(1).*exp(coeffs(2).*x) + coeffs(3).*exp(coeffs(4).*x);
        end