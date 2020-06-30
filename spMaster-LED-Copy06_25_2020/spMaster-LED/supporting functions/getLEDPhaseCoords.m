function [xCoord, yCoord] = getLEDPhaseCoords(trial, phase)

%convert direction and degree to x and y coordinates on auxiliary axis
if strcmp(trial(phase).direction, 'center')
    xCoord = 0;
    yCoord = 0;
elseif strcmp(trial(phase).direction, 'N')
    xCoord = 0;
    yCoord = trial(phase).degree;
elseif strcmp(trial(phase).direction, 'S')
    xCoord = 0;
    yCoord = -trial(phase).degree;
elseif strcmp(trial(phase).direction, 'E')
    xCoord = trial(phase).degree;
    yCoord = 0;
elseif strcmp(trial(phase).direction, 'W')
    xCoord = -trial(phase).degree;
    yCoord = 0;
elseif strcmp(trial(phase).direction, 'NW')
    xCoord = -trial(phase).degree * cosd(45);
    yCoord = trial(phase).degree * sind(45);
elseif strcmp(trial(phase).direction, 'NE')
    xCoord = trial(phase).degree * cosd(45);
    yCoord = trial(phase).degree * sind(45);
elseif strcmp(trial(phase).direction, 'SW')
    xCoord = -trial(phase).degree * cosd(45);
    yCoord = -trial(phase).degree * sind(45);
elseif strcmp(trial(phase).direction, 'SE')
    xCoord = trial(phase).degree * cosd(45);
    yCoord = -trial(phase).degree * sind(45);
end

end