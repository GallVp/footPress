function [ peakPressure ] = computeFootPPS( footData, intervals )
%computeFootPPS Splits the frames according to given intervals and 
%   finds peak pressure for each interval by following method.
%   1. Finds maximum value for each sensel across all frames in 
%   the interval.
%   2. Finds the number 'n' of nonzero and non-nan sensels.
%   3. Peak pressure = sum across all maximum values / n.
%
%   Inputs:
%   footData is a structure with following fields:
%       a. frames is a 3D  matrix  with sensel  values across rows
%       and columns, and frames across the third dimension.
%       b. timeVect a row or column vector containg time points
%       corresponding to frames.
%   intervals is a vector containg time points for intervals. 
%   Example: [a b c] would result in two intervals as follows:
%   [a b] and [b c].
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

frames = split3DMat(footData.frames, footData.timeVect, intervals);

peakPressure = zeros(size(frames, 1), 1);

for i = 1:size(frames, 1)
    pp = max(frames{i},[], 3);
    n = sum(sum(~isnan(pp) & pp ~=0));
    peakPressure(i) = nansum(nansum(pp)) / n;
end
end