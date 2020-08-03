%% Test function for plotting photodiode info from data table
function plotPhotodiode(data)  
%convert table to matrix
data = data{:,:};
%time is first column of data table/matrix
time = data(:,1);
%voltages read by photodiode is sixth column of data table/matrix
photo = data(:,6);
%plot x vs y
plot(time,photo);
end