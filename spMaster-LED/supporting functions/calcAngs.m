%% Calculate vergence angle and visual angle from xz coordinates
function [VisAng, VergAng] = calcAngs(x,z,Ihalf)
Dx = x - 67.31;
Dz = z + 33.02; 
Dc = hypot(Dx,Dz);
VisAng = atand(Dx./Dz);
VergAng = 2.*atand(Ihalf./Dc);
end