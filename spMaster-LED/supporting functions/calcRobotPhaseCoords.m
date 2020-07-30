%% Calculate coordinates in xz-space given a vergence angle and visual angle
function [xCoord,zCoord] = calcRobotPhaseCoords(VisAng,VergAng,Ihalf)
% Ihalf is half the interpupillary distance of the subject
%
% x and z coordinates are in units of cm from the corner/origin of the 
% robot (where stationary motor is mounted)
%
% with respect to the visual angle of interest, Dx is the opposite leg of
% the right triangle (distance from 0 degrees, straight ahead center of 
% visual field), Dz is the adjacent leg of the right traingle, Dc is the 
% hypotenuse of the right triangle (overall distance from the cyclopean eye)
%
% hard-coded numbers originate from actual dimensions of the robot in the
% rig and distance of monkey from the robot when placed in the rig
% 
% conversion from xz coordinates (Cartesian coordinates) to visual angle 
% and vergence angle (new set of coordinates) requires changing origin 
% location to the subject's cyclopean eye, which is 33.02 cm from the
% closest robot LED location in z dimension and 67.31 cm from the xz origin
Dc = Ihalf./tand(VergAng./2);
Dz = sqrt(Dc.^2./(tand(VisAng).^2+1));
Dx = sqrt(Dc.^2-Dz.^2);
idx = find(VisAng<0);
Dx(idx) = -Dx(idx);
xCoord = Dx + 63.31;
zCoord = Dz - 33.02;
end