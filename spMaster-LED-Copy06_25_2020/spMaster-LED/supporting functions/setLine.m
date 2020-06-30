function setLine(dio, line, value)
    global outputValue %also declared in krConnectDAQInf.m
    outputValue(line + 1) = value; %explain this: why line+1? what is value?
    outputSingleScan(dio,outputValue); %what is a "scan" in outputSingleScan?
end

