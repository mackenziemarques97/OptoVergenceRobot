clear
comPort = serial('COM5','DataBits',8,'StopBits',1,'BaudRate',9600,'Parity','none');
fopen(comPort);

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

delay_array = rand(1,56);

% output = check(comPort) %should receive Beginning

 output = check(comPort) %should receive "ReadyToReceiveDelays"
 sendArray(comPort, delay_array);
 output = check(comPort) %should receive "ForwardCoeffsReceived"
 
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