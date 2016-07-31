function varargout=duplicate(varargin)
% function [a1 a2 ...]=duplicate(a1, a2, ...);
%
% Duplicate scalars parameters so that they have same dimension as others.
% Empty arrays are unchanged
%

if nargin==0
    return
end
vin=varargin;
is=cellfun(@isscalar,vin);
ie=cellfun(@isempty,vin);
vv=vin(~is & ~ie); % argument that are not scalar or empty
if isempty(vv)
    varargout=vin;
    return
else
    nd=cellfun(@ndims,vv);
    if length(nd)>1 && all(nd==2) && automesh(vv{:}) % duplicate vectors
        vout=vin;
        [vout{1:end}] = ndgrid(vin{:});
        varargout=vout;
    elseif all(nd==nd(1))
        ns=cellfun(@size,vv,'UniformOutput',0);
        if any(cellfun(@(nsk) any(nsk-ns{1}),ns))
            error(sprintf('duplicate: incompatible input\n  Rotate inputs for automesh'));
        else
            vout=vin;
            z=zeros(ns{1});
            vout(is)=cellfun(@(s) s+z, vout(is), 'Uniformoutput', 0);
            varargout=vout;
        end
    else
        error(sprintf('duplicate: incompatible input\n  Rotate inputs for automesh'));
    end
end

function tf = automesh(varargin)
%AUTOMESH returns true if the inputs should be passed to meshgrid.
%   AUTOMESH(X,Y,...) returns true if all the inputs are vectors and the
%   orientations of all the inputs are not the same. 

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2005/12/12 23:26:21 $

tf = false;
if all(cellfun(@isvector,varargin))
   % Location of non-singleton dimensions
   ns = cellfun(@(x)size(x)~=1, varargin, 'UniformOutput', false);
   % True if not all inputs have the same non-singleton dimension. 
   tf = ~isequal(ns{:});
end