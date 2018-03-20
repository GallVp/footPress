function [AP, PM, ML] = valentiniCOP(copTrajectory, footData, intervals)
%valentiniCOP Computes per frame AP, PM, ML as used by 
%   Valentini et. al. For details see following publication:
%   Valentini, F. A., B. Granger, D. S. Hennebelle, N. Eythrib, 
%   and G. Robain. "Repeatability and variability of 
%   baropodometric and spatio-temporal gait parameters?results in 
%   healthy subjects and in stroke patients." Neurophysiologie 
%   Clinique/Clinical Neurophysiology 41, no. 4 (2011): 181-189.
%
%   Inputs:
%   copTrajectory is a 2D matrix  in which columns are (x, y)
%   coordinates and rows  correspond to frames.
%   footData is a structure with following fields:
%       a. leftFootData
%       b. rightFootData
%       Both these variables are structures. See readFscanData.m
%   intervals is a vector containg time points for intervals. 
%   Example: [a b c] would result in two intervals as follows:
%   [a b] and [b c].
%
%   Outputs:
%   AP, PM, ML (units mm) are vectors with lengths equal to number
%   of frames.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

METER_TO_MM_FACTOR = 1000;

frames = split3DMat(footData.frames, footData.timeVect, intervals);

for i = 1:size(frames, 1)
    frames{i} = max(frames{i},[], 3);
end

AP = zeros(size(frames, 1), 1);
PM = zeros(size(frames, 1), 1);
ML = zeros(size(frames, 1), 1);

trajectoryXMin = cellfun(@min,splitVector(copTrajectory(:, 1), footData.timeVect, intervals));
trajectoryYMin = cellfun(@min,splitVector(copTrajectory(:, 2), footData.timeVect, intervals));

trajectoryXMax = cellfun(@max,splitVector(copTrajectory(:, 1), footData.timeVect, intervals));
trajectoryYMax = cellfun(@max,splitVector(copTrajectory(:, 2), footData.timeVect, intervals));


for i = 1:size(frames, 1)
    ap = (trajectoryYMax(i) - trajectoryYMin(i)) * footData.rowSpacing * METER_TO_MM_FACTOR;
    if(isempty(ap))
        AP(i) = NaN;
    else
        AP(i) = ap;
    end
    
    ml = (trajectoryXMax(i) - trajectoryXMin(i)) * footData.colSpacing * METER_TO_MM_FACTOR;
    if(isempty(ml))
        ML(i) = NaN;
    else
        ML(i) = ml;
    end
    heelTip = frames{i};
    [heelTipY, ~, ~] = find(heelTip ~= 0 & ~isnan(heelTip));
    
    heelpTip = max(heelTipY);
    pm = (heelpTip - trajectoryYMax(i)) * footData.rowSpacing * METER_TO_MM_FACTOR;
    if(isempty(pm))
        PM(i) = NaN;
    else
        PM(i) = pm;
    end
end
end