%% Trial Struct Test
load('StructTest.mat');
paramNames_LED = {'phaseNum','color','direction','visAng','duration','fixDur','ifReward','withNext'};
paramNames_robot = {'phaseNum','color','xCoord','zCoord','vergAng','visAng','duration','ifReward','withNext'};
[Trial,totNumPhase,numLEDPhases,numRobotPhases,LEDPhases,robotPhases] = makeTrialStruct(TrialParams_LED,TrialParams_robot,paramNames_LED,paramNames_robot);
