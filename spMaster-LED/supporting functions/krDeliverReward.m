function krDeliverReward(dio)
    setLine(dio,1,1); % turn bit ON; 
    pause(0.001); %wait short delay
    setLine(dio,1,0); % turn bit OFF;
    pause(0.001);
end