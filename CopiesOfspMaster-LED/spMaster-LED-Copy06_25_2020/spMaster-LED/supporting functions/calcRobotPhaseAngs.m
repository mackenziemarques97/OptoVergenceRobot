%% Calculate vergence angle and visual angle from xz coordinates
function [VisAng, VergAng] = calcRobotPhaseAngs(x,z,Ihalf)
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
Dx = x - 67.31;
Dz = z + 33.02; 
Dc = hypot(Dx,Dz);
VisAng = atand(Dx./Dz);
VergAng = 2.*atand(Ihalf./Dc);
end