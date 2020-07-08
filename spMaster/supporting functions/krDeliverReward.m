function krDeliverReward(dio, numrew)

for r = 1:numrew
    setLine(dio,1,1); % turn bit ON; 
    pause(0.05); %wait short delay
    setLine(dio,1,0); % turn bit OFF;
    pause(0.05);
end