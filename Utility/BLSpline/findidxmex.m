% function idx=findidxmex(xgrid, xi)
%
% mex findidxmex.c
% function called by find_idx.m
% Dichotomy search of indices
% Calling:
%   idx=findidxmex(xgrid, xi);
%   where xgrid and xi are double column vectors
%    xgrid must be sorted in the ascending order
% Compile:
%  mex -O -v findidxmex.c
% Author: Bruno Luong
% Original: 19/Feb/2009
