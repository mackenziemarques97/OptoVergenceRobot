function data_out = krGetTrialSpikes(data_main_dir)
    %% Pull in spike data
    fr = fopen(fullfile(data_main_dir,'Data.bin'),'r');
    data = fread(fr,[7,Inf],'double');
    spike = data(3,:)';
    t = data(7,:)';
    t = t - min(t);
    fclose(fr);
    %% Filter out spikes
    THRESH_DVDT = 300; %threshold change in voltage for detecting a high bit from the CED
    dt = t(2) - t(1);
    spike_times = t(diff(spike) / dt > THRESH_DVDT);
    spike_times = round(spike_times * 1000) / 1000; %downsample spike times to 1 / ms
    spike_times = unique(spike_times); %filter out any duplicates (max rate is 1000 / sec)
    t_subsamp = (0:.001:max(t))'; 
    spikes_subsamp = zeros(size(t_subsamp));
    spikes_subsamp(round(1 + spike_times*1000)) = 1;
    %Due to the rounding performed above, sometimes spikes_subsamp contains
    %one more row entry than the rest of the data variables, and this
    %causes the table formation (last line of function) to throw an error.
    if length(t_subsamp) ~= length(spikes_subsamp)
        spikes_subsamp = spikes_subsamp(1:end-1);
    end
    %Build Output table
    eye_pos_x_1 = resample(timeseries(data(1,:)',t),t_subsamp);
    eye_pos_y_1 = resample(timeseries(data(2,:)',t),t_subsamp);
    photodiode = resample(timeseries(data(4,:)',t),t_subsamp);
    eye_pos_x_2 = resample(timeseries(data(5,:)',t),t_subsamp);
    eye_pos_y_2 = resample(timeseries(data(6,:)',t),t_subsamp);
    data_out = table(1000*t_subsamp,eye_pos_x_1.Data,eye_pos_y_1.Data,eye_pos_x_2.Data,eye_pos_y_2.Data,photodiode.Data,spikes_subsamp,'VariableNames',{'Time','Eye_Position_X_1','Eye_Position_Y_1','Eye_Position_X_2','Eye_Position_Y_2','Photodiode','Spikes'});
end