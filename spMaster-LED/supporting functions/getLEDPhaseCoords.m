function [xCoord, yCoord] = getLEDPhaseCoords(Trial, phaseNum)
dir = Trial(phaseNum).phases.direction;
deg = Trial(phaseNum).phases.visAng;

%convert direction and degree to x and y coordinates on auxiliary axis
if strcmp(dir, 'center')
    xCoord = 0;
    yCoord = 0;
elseif strcmp(dir, 'N')
    xCoord = 0;
    yCoord = deg;
elseif strcmp(dir, 'S')
    xCoord = 0;
    yCoord = -deg;
elseif strcmp(dir, 'E')
    xCoord = deg;
    yCoord = 0;
elseif strcmp(dir, 'W')
    xCoord = -deg;
    yCoord = 0;
elseif strcmp(dir, 'NW')
    xCoord = -deg * cosd(45);
    yCoord = deg * sind(45);
elseif strcmp(dir, 'NE')
    xCoord = deg * cosd(45);
    yCoord = deg * sind(45);
elseif strcmp(dir, 'SW')
    xCoord = -deg * cosd(45);
    yCoord = -deg * sind(45);
elseif strcmp(dir, 'SE')
    xCoord = deg * cosd(45);
    yCoord = -deg * sind(45);
end

end