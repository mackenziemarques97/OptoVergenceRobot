%% Practice with PROGMEM storage

comPort = serial('COM8','DataBits',8,'StopBits',1,'BaudRate',9600,'Parity','none');
fopen(comPort);

SerialInit = 'X';
while(SerialInit~='A')
    SerialInit = check(comPort);
end
if SerialInit ~= 'A'
    disp('Serial Communication Not Setup');
else
    disp('Serial Read');
end
fprintf(comPort, '%s', 'A');
flushinput(comPort);

waitSignal = check(comPort)
fclose(comPort);

function waitSignal = check(comPort)
    data = '';
    while(1)
        data = fscanf(comPort, '%s');
        if isempty(data) == 1
            data = fscanf(comPort, '%s');
            %1
        elseif isempty(data) == 0
            %disp(data);
            waitSignal = data;
            %2
            break;
        end
    end
end


% X = rand(1,60);
% valuesReceivedX = zeros(size(X));
% 
% sendArray(comPort, X);
% 
% for i = 1:numel(X)
%     valuesReceivedX(i) = fscanf(comPort, '%f');
% end
% 
% fclose(comPort);
% %% sendArray function
% %takes in array of values
% %converts array to a string that with : delimiter
% %sends string to Arduino
% 
% function sendArray(comPort, array)
% str = inputname(2);
% strList = sprintf(':%f', array);
% strToSend = [str strList];
% fprintf(comPort, strToSend);
% end