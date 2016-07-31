%Modified from:

% *************************************************************************
%                 TWO DIMENSIONAL ELEMENT FREE GALERKIN CODE
%                            Nguyen Vinh Phu
%                        LTDS, ENISE, Juillet 2006
% *************************************************************************
function [w,dwdn] = circle_splineND(x,xI,d,form)
% Compute cubic and quartic spline function
% Inputs:
% x (1x2)  : coordinate of point at which w is to be evaluated
% xI (1x2) : coord of node I
% d        : size of the support

dimension = size(x,2);

r = pdist([x;xI],'euclidean')/d;

switch form
  case 'cubic_spline' 
     [w,dwdr] = cubic_spline(r);
  case 'quartic_spline'
     [w,dwdr] = quartic_spline(r);
  otherwise 
     error('Grr. Unknown functional form');
end

if (r ~= 0)
    
    drdn = (x-xI)/(r*d*d);

else
    drdn = zeros(1,dimension);
end

dwdn = dwdr * drdn ;

