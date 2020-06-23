%% calculate visual angle limits
Dz = [33.02 33.02+86.0425 33.02 33.02+86.0425];
Dx = [0 0 67.31 67.31];
Dz_VergAng = [Dz(1:2) hypot(Dz(1:2),67.31)];
VisAng = atand(Dx./Dz);
VergAng = 2*atand((3.4/2)./Dz_VergAng);