function  [rasterFig, sdfFig, sdfLimit] = dirRaster(nTrials, rasterData, targLocInd, isClear, rasterFig, sdfFig, sdfLimit)
global trialCounterVar
global rasterDataAll
titles = {'Right', 'Top Right', 'Top', 'Top Left', 'Left', 'Bottom Left', 'Bottom', 'Bottom Right'};
sdfWindow = 101; %standard deviation of 20 (1/5th of window) for Gaussian kernel

%% check for isClear
if isClear 
   trialCounterVar = ones(1,8);
   rasterDataAll = NaN(nTrials, 351, 8); %[# trials, time points aligned to trial event, types of trials]
end

%% plot rasters and SDF on each trial

photoEvent = find(diff(rasterData.Photodiode) < -2, 1, 'first'); %stimulus event
rasterSpikes = rasterData.Spikes(photoEvent - 100: photoEvent + 250); %spikes 100ms before and 500ms after
time = -100:1:250;
rasterDataAll(trialCounterVar(targLocInd), :, targLocInd) = (rasterSpikes*1000)';
sdf = smoothdata(nanmean(rasterDataAll(:, :, targLocInd), 1), 'gaussian', sdfWindow);

%plot raster
figure(rasterFig)
subplot(4, 2, targLocInd)
plot(time, rasterSpikes*trialCounterVar(targLocInd), 'k.')
hold on
title(titles{targLocInd})
drawnow

%plot SDF
figure(sdfFig)
if max(sdf) > sdfLimit
    sdfLimit = max(sdf);
     for subplotInd = 1:8
        subplot(4, 2, subplotInd)
        title(titles{subplotInd})
        line([0 0], [0 sdfLimit])
        hold on              
        ylim([0 sdfLimit])
        xlim([-100 250])
     end
end
subplot(4, 2, targLocInd)
cla
plot(time, sdf, 'color', 'r', 'LineWidth', 2);
hold on
line([0 0], [0 sdfLimit])
hold on
title(titles{targLocInd})
drawnow

trialCounterVar(targLocInd) = trialCounterVar(targLocInd) + 1;

end

