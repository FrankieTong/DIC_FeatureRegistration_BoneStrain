%{
This file is part of the McGill Digital Image Correlation Research Tool (MDICRT).
Copyright © 2008, Jeffrey Poissant, Francois Barthelat

MDICRT is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MDICRT is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MDICRT.  If not, see <http://www.gnu.org/licenses/>.


% Digital Image Correlation: Max-Min Filter
% Honours Thesis Research Project
% McGill University, Montreal, Quebec, Canada
% Created on:  Novemeber 1, 2007
% Modified on: Novemeber 1, 2007


-----------------------------------------------------------
|   DIGITAL IMAGE CORRELATION: Max-Min Filter             |
-----------------------------------------------------------

The following function will be called to filter the Bad_Values matrix and fill in any gaps.
%}

function [DEFORMATION_PARAMETERS, good_corr] = NaN_Value_Averaging(good_corr, DEFORMATION_PARAMETERS)