%% Calculate coordinates in xz-space given a vergence angle and visual angle
function [xCoord,zCoord] = calcRobotCoords(VisAng,VergAng,Ihalf)
Dc = Ihalf./tand(VergAng./2);
Dz = sqrt(Dc.^2./(tand(VisAng).^2+1));
Dx = sqrt(Dc.^2-Dz.^2);
idx = find(VisAng<0);
Dx(idx) = -Dx(idx);
xCoord = Dx + 67.31;
zCoord = Dz - 33.02;
if xCoord < 0 || xCoord > 134.62 
    str = sprintf('X-coordinate out of bounds. Invalid visual/vergence angle combination.');
    uiwait(msgbox(str,'Error','error'));
end
if zCoord < 0 || zCoord > 86.0425
    str = sprintf('Z-coordinate out of bounds. Invalid visual/vergence angle combination.');
    uiwait(msgbox(str,'Error','error'));
end
end