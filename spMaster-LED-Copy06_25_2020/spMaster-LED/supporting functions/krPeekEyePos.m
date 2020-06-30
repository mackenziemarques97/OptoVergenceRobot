function [eyePosX, eyePosY] = krPeekEyePos(data_main_dir)
DOUBLE_SIZE = 8;
n_channels = 7;
fr = fopen(fullfile(data_main_dir,'Data.bin'),'r');
fseek(fr,-n_channels*DOUBLE_SIZE,'eof');
data = fread(fr,[7,1],'double');
eyePosX = data(1)*100;
eyePosY = data(2)*100;
fclose(fr);
end
