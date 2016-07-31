function appxZero = phiThicknessRefractiveIndexEquationSet( phiDMB0, Nsol, NDMBi, thicknessi, Ncompi, t0)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
equationsCount = size(NDMBi,1);
appxZero = ones(equationsCount,1);

for i = 1:equationsCount
    appxZero(i)= t0/thicknessi(i) - (Nsol-Ncompi)/(phiDMB0*(Nsol-NDMBi(i)));
end

end

