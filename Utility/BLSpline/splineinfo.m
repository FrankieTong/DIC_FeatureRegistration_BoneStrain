function varargout = splineinfo(s, varargin)
%
% function [V1 V2, ...] = splineinfo(s, Property1, Property2, ...)
%
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

Properties = {'ndim' 'nvar' 'grid' 'data' 'value'};
expr=sprintf('%s|',Properties{:});
expr=['(' expr(1:end-1) ')'];
InputStr = varargin;
if ~isempty(InputStr) && ~ischar(InputStr{end})
    dflag = InputStr{end};
    InputStr(end) = [];
else
    dflag = 0;
end

Plist = regexp(InputStr,expr,'match');

iempty = cellfun(@isempty,Plist);
if any(iempty)
    error('splineinfo: %s is not a valid property', ...
        InputStr{find(iempty,1,'first')});
end

% Take a unique of all input properties
Plist = cellfun(@(c) c{1},Plist,'UniformOutput',false);
% [Punique dummy J] = unique(char(Plist),'rows');
% Punique = reshape(cellstr(Punique),1,[]);
[Punique dummy J] = unique(Plist); %#ok
Punique = reshape(Punique,1,[]);

results = cell(size(Punique));
[results{:}] = splineinfo_nocheck(s, Punique{:}, dflag);
results = results(J);

varargout = cell(1,max(nargout,length(results)));
varargout(1:length(results)) = results;

end

