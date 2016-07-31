function [order varargout] = isgrid(varargin)
% 
% [order x1 x2 ... xn]=isgrid(X1,X2,X3,...Xn)
%
%
% This function returns the reverse of
%
% [X1 X2 ... Xn] = ndgrid(x1, x2, ... xn)
%   X1 = permute(X1, order)
%   X2 = permute(X2, order)
%   ...
%   Xn = permute(Xn, order)
%
% where order is a permutation array of (1:n)
%
% Failure:
% - If X1, ... Xn is not generated as such, then
%    order is zero and x1, ..., xn are empty

% Default value
order = 0;
nd = nargin;
X = varargin;
grid = cell(1,nd);
varargout = grid(1:nargout-1);

% Check dimension
if any(cellfun(@(Xk) (ndims(Xk)~=nd),X))
    return
end
% Check compatible size
if any(cellfun(@(Xk) ~all(size(Xk)==size(X{1})),X))
    return
end

% Permutation array
p=(1:nd);

% Loop on input variables
for k=1:nd
    Xk = X{k};
    % dimension not yet populated
    dfree = find(cellfun(@(c) isempty(c), grid));
    dimfind = 0;
    for d=reshape(dfree,1,[])
        subs=num2cell(ones(1,nd));
        subs{d}=':';
        sr = struct('type','()','subs', {subs});
        % extract a vector along d-dimension of Xk
        Xkd = subsref(Xk,sr);
        % singleton
        if length(unique(Xkd(:)))==1
            continue
        else % vector
            sz = size(Xk);
            sz(d) = 1;
            % check if Xk is repmat
            if all(reshape(repmat(Xkd, sz),[],1)==Xk(:))
                dimfind = d;
                grid{d}=reshape(Xkd,[],1);
                p(k) = d;
                break % OK, go to next array
            else
                return
            end
        end
    end
    
    if ~dimfind % not finding, check if the whole array has unique value
        if all(Xk(:)==Xk(1)) % unique value
            d=dfree(1); % Pick the first dimension to try (could be others) 
            % generate a long vector of the same length than d-dimension
            % of Xk
            grid{d}=Xk(1)+zeros(size(Xk,d),1);
            p(k) = d;
        else % more than one value, not OK
            return
        end
    end
end

order(p)=1:length(p);
varargout = grid(p(1:nargout-1));