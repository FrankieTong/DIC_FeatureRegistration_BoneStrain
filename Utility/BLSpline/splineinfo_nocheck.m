function varargout = splineinfo_nocheck(s, varargin)
%
% function [V1 V2, ...] = splineinfo_nocheck(s, Property1, Property2, ..., dflag)
%
% Get the info from splinend structure
%
% Property are among string: 'ndim', 'nvar', 'grid', 'data', 'value'
% The Output Vi are returned in the order properties Propertyi:
%    ndim, nvar  -> number of dimensions
%    grid -> list of linear grids on each dimension
%    data, value -> ND data used to generate the spline function s
%
% splinegriddata(s, 'data', [0 2 0 2]) <- derivative in each dimension
% splinegriddata(s, 'data', [i1 ... in d1 ... dn]) subindice &
%                                           derivative in each dimension
% the dimension with NaN indice will be extracted
%
% Author: Bruno Luong
% Last Update: 10/August/2009
%

dflag = varargin{end};
Punique = varargin(1:end-1);
results = cell(1,nargout);

if isfield(s,'economy')
    for k=1:length(Punique)
        P = Punique{k}; % Property
        switch P
            case {'ndim' 'nvar'},
                results{k} = length(s.xgrid);
            case 'grid',
                if ~exist('grid','var')
                    grid = s.xgrid;
                end
                results{k} = grid;
            case {'data' 'value'},
                ngrid = cellfun(@length,s.xgrid);
                n = length(ngrid);
                
                [tensorindex dflag] = getindex(dflag, n);
                
                index = [tensorindex dflag];
                subs=num2cell(index);
                subs(isnan(index)) = {':'};
                sr = struct('type','()','subs', {subs});
                
                data = subsref(s.tensordata,sr);
                
                % Remove singleton
                sizedata = size(data);
                sizedata(end+1:length(index)) = 1;
                sizedata(~isnan(index)) = [];
                if isempty(sizedata)
                    sizedata = [1 1];
                elseif length(sizedata)==1
                    sizedata = [1 sizedata]; %#ok
                end
                
                data = reshape(data, sizedata);
                
                results{k} = data;
        end
    end
else
    for k=1:length(Punique)
        P = Punique{k}; % Property
        switch P
            case {'ndim' 'nvar'},
                results{k} = getndim(s);
            case 'grid',
                if ~exist('grid','var')
                    grid = getgrid(s);
                end
                results{k} = grid;
            case {'data' 'value'},
                if ~exist('grid','var')
                    grid = getgrid(s);
                end
                ngrid = cellfun(@length,grid);
                
                [tensorindex dflag] = getindex(dflag, length(ngrid));
                
                data = zeros(ngrid);
                prodsize = [1 cumprod(ngrid)];
                filldata(s, 1, 1);
                
                index = tensorindex;
                subs=num2cell(index);
                subs(isnan(index)) = {':'};
                sr = struct('type','()','subs', {subs});
                
                data = subsref(data,sr);
                
                % Remove singleton
                sizedata = size(data);
                sizedata(end+1:length(index)) = 1;
                sizedata(~isnan(index)) = [];
                if isempty(sizedata)
                    sizedata = [1 1];
                elseif length(sizedata)==1
                    sizedata = [1 sizedata]; %#ok
                end
                
                data = reshape(data, sizedata);
                
                results{k} = data;
        end
    end
end

% populate recursively the array data
    function filldata(s, idx, d)
        if isstruct(s.zz)
            nextd=d+1;
            if dflag(d)==2
                for i=1:length(s.zz)
                    filldata(s.zzxx(i), idx+(i-1)*prodsize(d), nextd);
                end
            else
                for i=1:length(s.zz)
                    filldata(s.zz(i), idx+(i-1)*prodsize(d), nextd);
                end
            end
        else
            if dflag(d)==2
                data(idx+(0:length(s.zz)-1)*prodsize(d)) = s.zzxx;
            else
                data(idx+(0:length(s.zz)-1)*prodsize(d)) = s.zz;
            end
        end
    end

varargout = results;

end

function [tensorindex dflag] = getindex(dflag, n)
if length(dflag)>n
    if length(dflag)==2*n
        tensorindex = dflag(1:n);
        dflag = dflag(n+1:end);
    else
        error('splineinfo: dflag length must be %d or %d', ...
            n, 2*n);
    end
else
    % take entire array by default
    tensorindex = nan(1,n);
end

% make sure dflag is 1 or 2
dflag(end+1:n)=1;
dflag(dflag~=2 & ~isnan(dflag))=1;

end

function ndim = getndim(s)
if isstruct(s.zz)
    ndim = 1 + getndim(s.zz(1));
else
    ndim = 1;
end
end

function grid = getgrid(s)
if isstruct(s.zz)
    grid = [{s.xgrid} getgrid(s.zz(1))];
else
    grid = {s.xgrid};
end
end

