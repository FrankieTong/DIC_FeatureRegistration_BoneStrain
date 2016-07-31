function res = evalfct(funstruct, varargin)
% function f = evalfct(funstruct, x); OR % 1D case
% f = evalfct(funstruct, x, y); OR % 2D case
% f = evalfct(funstruct, x, y, z); OR % 3D case
% f = evalfct(funstruct, x1, x2, x3, ...); % ND-CASE
%
% Evaluate the interpolation functions:
% INPUT
%   funstruct: is the structure contains the description of
%       interpolation function
%   (x, y, z,...), points where funcion will be evaluated
% OUTPUT
%   f: function value
%
% Last update: 06/August/2008: spline ND
%              23/Oct/2008: extendedfun_nd
%              09/Jan/2009: composedfcn_nd
%              11/Aug/2009: short version for SPLINEND FEX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isnumeric(funstruct) % Polynomial coefficients
    funstruct = struct('Tag', 'poly1d',...
                       'coefs', funstruct);
end

Tag = funstruct.Tag;

% Order of the variable, by default same order when building structure
varorder=getoption(funstruct,'varorder',(1:length(varargin)));

%
% Get the input parameters
%
if strfind(Tag, 'nd') % ND interpolation
    xilist=cell(1,funstruct.nvar);
    [xilist{:}] = duplicate(varargin{varorder});
else
    switch getdim(funstruct)
        case 1, % 1D interpolation
            [xi] = deal(varargin{varorder(1)});
        case 2, % 2D interpolation
            [xi, ti] = duplicate(varargin{varorder(1:2)});
        case 3, % 3D interpolation
            [xi, yi, zi] = duplicate(varargin{varorder(1:3)});
    end
end

%
% Call appropriate interpolation function
%
switch Tag
    case {'spline1d structure'} % spline 1d
        res = spline1d([], [], xi, funstruct);
    case {'splinend structure'} % polynomial nd
        dummy=cell(1,funstruct.nvar+1);
        res = splinend(funstruct.nvar, dummy{:}, xilist{:}, funstruct);
    otherwise
        error('evalfct: unknown tag (methode)');
end