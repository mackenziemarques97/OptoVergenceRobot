function buffData(src,event)
    %% Timer to get interval for refresh
    %global tonytimer
    %toc(tonytimer)
    %tonytimer = tic;
    %% Timer to get duration of each refresh
    global fw
    buffData = event.Data;
    buffTime = event.TimeStamps;
    fwrite(fw,[buffData buffTime]','double');
end