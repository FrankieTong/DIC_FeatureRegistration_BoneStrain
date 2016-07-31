function idx=find_idx(xi, xgrid, options, InputCheck)
% function idx=find_idx(xi, xgrid)
% function idx=find_idx(xi, xgrid, 'extrap')
% 
% Purpose: bins of array 'xi' in the container 'xgrid'
%
% INPUT
%   xgrid: is a sorted array (ascending or descending)
%   xi: array of points
%   CALL idx = find_idx(..., InputCheck)
%      InputCheck [false]: optional boolean flag, force check whereas
%                          xgrid is sorted
% OUTPUT
%   idx: fractional indices of xi in xgrid, same size as xi
%       - The first element starts from 1
%       - The fractional part is calculated as linear interpolation
%         between two brakets
% Algorithm: dichotomy, complexity of m.log(n), where m is number of data
%   points (xi) and n is number of bins (xgrid)
%
% Note 1: This function is equivalent to
%   idx = interp1(xgrid,(1:length(xgrid)),xi,'linear',options)
%   except that overflow values are clipped (interp1 returns NaN).
%   Speed improvement is about 5 times
% Note 2: round(idx) is equivalent to interp1(..., 'nearest')
% Note 3: floor(idx) is equivalent to [trash idx] = histc(xi, xgrid)
%        except overflow values
%
% Call mex function findidxmex.c,
%    compile command: >> mex -O -v findidxmex.c
%
% Example: bining 1 billions data points into 1000 intervals
%   xgrid=cumsum(3*rand(1,1000));
%   xi=rand(1,1e6)*2000;
%   idx=find_idx(xi, xgrid,'extrap');
%
% Author: Bruno Luong
% Original: 19/Feb/2009
%           20/Feb/2009, spare called interp1 when compiled
%              mex engine does not exist

persistent mexexist

% Check if mex file exists
if isempty(mexexist)
    mexexist = false;
    mexloc = which('findidxmex');
    if ~isempty(mexloc)
        [pname fname ext] = fileparts(mexloc);
        mexexist = ~strcmpi(ext,'.m');
    end
    if ~mexexist
        warning('find_idx:MexNotCompiled', ...
                'find_idx: mex engine is not compiled, interp1 invokes');
        fprintf('\tRecommendation action: compile then reset by\n');
        fprintf('\t>> mex -O -v findidxmex.c\n');
        fprintf('\t>> clear find_idx');
        
    end
end

if nargin<4 || isempty(InputCheck)
    InputCheck=false; % Not checking by default
end

if InputCheck
    if ~isvector(xgrid) || (~issorted(xgrid) && ~issorted(-xgrid))
        error('find_idx: xgrid must be sorted vector');
    elseif any(diff(xgrid)==0)
        error('find_idx: xgrid elements must be distinct');
    end
end

nx=length(xgrid);

descending = (nx>0) && xgrid(nx)<xgrid(1);
if descending % decending-order
    xgrid = xgrid(end:-1:1); % flip
end

% Cast if necessary
if ~strcmp(class(xgrid),'double')
    xgrid = double(xgrid);
end
if ~strcmp(class(xi),'double')
    xi = double(xi);
end

% Call the mex engine (dichotomy search)
if mexexist
    idx=findidxmex(xgrid(:),xi(:));
else % spare solution
    idx=interp1(xgrid,(1:length(xgrid)),xi,'linear','extrap');
end
if isempty(idx) && ~isempty(xi) % problem
    error('find_idx: out of memory');
end

if descending % decending-order
    idx = nx+1-idx;
end

% Hack the code here if you want different behaviour for overflowed data
if nargin<3 || ~strcmpi(options,'extrap')
    idx=max(min(idx,nx),1); % clipping
end

% Reshape the output
idx=reshape(idx,size(xi));

