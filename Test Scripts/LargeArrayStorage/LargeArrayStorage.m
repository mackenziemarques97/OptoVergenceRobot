%can send 55 "delays" in the current data format, but not more
clear
comPort = serial('COM5','DataBits',8,'StopBits',1,'BaudRate',9600,'Parity','none');
fopen(comPort);

save_filename = 'parameters.mat';
parameters = load(save_filename);
reverse_coeffs = parameters.reverse_coeffs;

SerialInit = 'X';
while(SerialInit~='A')
    0
    SerialInit = check(comPort);
end
if SerialInit ~= 'A'
    disp('Serial Communication Not Setup');
else
    disp('Serial Read');
end
fprintf(comPort, '%s', 'A');
flushinput(comPort);

diameter = 30;
angInit = 90;
angFinal = -90;
speed = 900;
numLines = 54;

dx = zeros(1,numLines); dy = zeros(1,numLines);
Delays = zeros(1,numLines); %preallocating
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
    angle = atan(dy(count) / dx(count) * 180/pi);
    Delays(count) = speedToDelay(speed, angle);
    count = count + 1;
end
%testing
Delays
size(Delays)
waitSignal = check(comPort) % should receive "ReadyToReceiveDelays"
sendArray(comPort, Delays);
waitSignal = check(comPort)


% % random playing with communication
% % send and receive a 5
% fprintf(comPort, '%s', '5');
%  output = check(comPort)
% % send and receive "Hello"
% fprintf(comPort, '%s', 'Hello');
%  output = check(comPort)

fclose(comPort);

function output = check(comPort)
data = '';
while(1)
    data = fscanf(comPort, '%s');
    if isempty(data) == 1
        data = fscanf(comPort, '%s');
        %1
    elseif isempty(data) == 0
        %disp(data);
        output = data;
        %2
        break;
    end
end
end

%% sendArray function
%takes in matrix of coeffcients
%converts matrix to a string that with : delimiter
%sends string to Arduino

function sendArray(comPort, array)
str = inputname(2);
strList = sprintf(':%f', array);
strToSend = [str strList]
fprintf(comPort, strToSend);
end

%% Calculating input speed to a delay sent to Arduino
% coeff_array is a 4x4 array - rows representing exp2, columns representing
% poly3
function [delay] = speedToDelay(speed,angle)
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