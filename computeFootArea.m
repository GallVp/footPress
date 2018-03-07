function [ area ] = computeFootArea( footData )
%computeFootArea Computes pe frame foot area from row spacing and 
%   column spacing. The units of  row  spacing and  column spacing 
%   are assumed to be meters. The  units of the computed  area are
%   mm squared.
%
%   Inputs:
%   footData is a structure with following fields:
%       a. frames is a 3D matrix with sensel  values across  rows 
%       and columns, and frames across the third dimension.
%       b. rowSpacing,  colSpacing Row and  Column spacing of each 
%       sensel (Units assumed to be meters) 
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

MSQUARED_TO_MMSQUARED_FACTOR    = 10^6;

area = ~isnan(footData.frames) & footData.frames ~= 0;
area = sum(sum(area, 1), 2);
area = area(:) .* footData.rowSpacing .* footData.colSpacing .* MSQUARED_TO_MMSQUARED_FACTOR;
end