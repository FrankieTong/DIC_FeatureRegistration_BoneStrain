function res = evalder(funstruct, ivar, varargin)
% function f = evalder(funstruct, ivar, x); OR % 1D case
% f = evalder(funstruct, ivar, x, y); OR % 2D case
% f = evalder(funstruct, ivar, x, y, z); OR % 3D case
% f = evalder(funstruct, ivar, x1, x2, x3, ...); % ND-CASE
%
% Evaluate the derivative of the interpolation functions
%
% INPUT
%   funstruct: is the structure contains the description of
%       interpolation function
%   ivar: integer 1 to Nvar, to tell with respect to which
%         variables; assuming f depends on Nvar input variables.
%   (x, y, z,...), points where derivative will be evaluated
% OUTPUT
%   f: function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(ivar) || nargin<2
    ivar=1;
end
derstruct=polyderiv(funstruct,ivar);
res = evalfct(derstruct, varargin{:});