function buffData(src,event)
%     fName = ['C:\Users\LabV\Documents\Divya\ssdTrainData\Skwiz\', date, '\' 'ssdTrain_' date '_' num2str(c(4)) num2str(c(5))]; % date and hour and min
%     fw = fopen([fName 'eyepos_sampled.bin'],'a');
    global buffData buffTime 
    buffData = event.Data;
    buffTime = event.TimeStamps;
%     fwrite(fw,[buffData buffTime]','double');
%     fclose(fw);
end