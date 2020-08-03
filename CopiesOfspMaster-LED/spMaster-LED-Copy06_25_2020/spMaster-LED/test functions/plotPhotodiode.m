function plotPhotodiode(data)  
data = data{:,:};
time = data(:,1);
photo = data(:,6);
plot(time,photo);
end