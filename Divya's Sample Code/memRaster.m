function [rasterFig, sdfFig, sdfLimit] = memRaster(nTrials, rasterData, xLocTarg, yLocTarg, isClear, rasterFig, sdfFig, sdfLimit)
global trialCounterVar
global visualAll
global delayAll
global motorAll
sdfWindow = 101; %standard deviation of 20 (1/5th of window) for Gaussian kernel
if isClear
    visualAll = NaN(nTrials, 351);
    delayAll = NaN(nTrials, 801);
    motorAll = NaN(nTrials, 601);
end

%find visual spikes and sdf for trial
photoEvent1 = find(diff(rasterData.Photodiode) < -2, 1, 'first');
visualSpikes = rasterData.Spikes(photoEvent1 - 100: photoEvent1 + 250);
visualTime = -100:1:250;
visualAll(trialCounterVar, :) = (visualSpikes*1000)';
visualSdf = smoothdata(nanmean(visualAll), 'gaussian', sdfWindow);

%find motor spikes and sdf for trial by aligning to eye movement
photoEvent2 = find(diff(rasterData.Photodiode) < -2, 1, 'last'); %fixation offset
if abs(xLocTarg) > 2
    vel = diff(rasterData.Eye_Position_X_1((photoEvent2:end)));
elseif abs(yLocTarg) > 2
    vel = diff(rasterData.Eye_Position_Y_1((photoEvent2:end)));
end
motorEvent = find(abs(vel) > 0.02, 1, 'first') + photoEvent2; 
if isempty(motorEvent)
    motorSpikes = NaN(1, 401);
else
    motorSpikes = rasterData.Spikes(motorEvent - 200: motorEvent + 200);
end
motorTime = -200:1:200;
motorAll(trialCounterVar, :) = (motorSpikes*1000)';
motorSdf = smoothdata(nanmean(motorAll), 'gaussian', sdfWindow);

delaySpikes = rasterData.Spikes((photoEvent1 + 50):photoEvent2);
delayTime = 1:1:length((photoEvent1 + 50):photoEvent2);
delayAll(trialCounterVar, 1:length((photoEvent1 + 50):photoEvent2)) = (delaySpikes*1000)';
delaySdf = smoothdata(nanmean(delayAll), 'gaussian', sdfWindow);

%plot raster
figure(rasterFig)
subplot(1, 3, 1)
plot(visualTime, visualSpikes*trialCounterVar, 'k.')
hold on
title('Visual')
subplot(1, 3, 2)
plot(delayTime, delaySpikes*trialCounterVar, 'k.')
hold on
xlim([0 800])
ylim([1 nTrials])
title('Delay')
subplot(1, 3, 3)
plot(motorTime, motorSpikes*trialCounterVar, 'k.')
hold on
xlim([-200 200])
title('Motor')

%plot raster
figure(sdfFig)
if max(visualSdf) > sdfLimit  || max(motorSdf) > sdfLimit || max(delaySdf) > sdfLimit
    sdfLimit = max([visualSdf, delaySdf, motorSdf]);
    subplot(1, 3, 1)
    title('Visual')
    line([0 0], [1 sdfLimit])
    hold on
    ylim([1 sdfLimit])
    xlim([-100 250])
    subplot(1, 3, 2)
    title('Delay')
    ylim([1 sdfLimit])
    xlim([0 800])
    subplot(1, 3, 3)
    title('Motor')
    line([0 0], [1 sdfLimit])
    hold on
    ylim([1 sdfLimit])
    xlim([-200 200])
end
subplot(1, 3, 1)
cla
plot(visualTime, visualSdf, 'color', 'r', 'LineWidth', 2);
hold on
line([0 0], [1 sdfLimit])
hold on
ylim([1 sdfLimit])
xlim([-100 250])

subplot(1, 3, 2)
cla
plot(0:1:800, delaySdf, 'color', 'r', 'LineWidth', 2);
hold on
ylim([1 sdfLimit])
xlim([0 800])
title('Delay')

subplot(1, 3, 3)
cla
plot(motorTime, motorSdf, 'color', 'r', 'LineWidth', 2);
hold on
line([0 0], [1 sdfLimit])
hold on
ylim([1 sdfLimit])
xlim([-200 200])

trialCounterVar = trialCounterVar + 1;
end
    
    
    
