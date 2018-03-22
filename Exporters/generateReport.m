function reportData = generateReport( footData,  intervals, maskData)
%generateReport Generates a report for given foot data both 
%   overall and according to intervals. Furthermore, the invalid 
%   sensels can be masked from analysis.
%
%   Inputs:
%   footData is a structure with following fields:
%       a. leftFootData
%       b. rightFootData
%       Both these variables are structures. See readFscanData.m
%   intervals is a vector containg time points for intervals. 
%   Example: [a b c] would result in two intervals as follows:
%   [a b] and [b c].
%   maskData is a structure with following variables:
%       a. leftMask, rightMask
%       Both these variables are 2D N by 3 matrices. N is the 
%       number of masked sensels. 1st column correspont to column
%       number, 2nd column corresponds to row number. And third
%       column is redundant and always has a zero value.
%
%   Outputs:
%   reportData is a structure with computed variables.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.



if nargin < 3
    maskData = [];
end

reportData.frameNum = (1:size(footData.leftFootData.frames, 3))';
reportData.time = footData.leftFootData.timeVect';
% exclude masked data
footData = excludeMaskedSensels(footData, maskData);

% Compute weight as percentage of total body weight
[~, reportData.leftWeight] = computeFootForce(footData.leftFootData);
[~, reportData.rightWeight] = computeFootForce(footData.rightFootData);

% Compute contact area
reportData.leftArea = computeFootArea(footData.leftFootData);
reportData.rightArea = computeFootArea(footData.rightFootData);

% Compute cop trajectory
reportData.leftTrajectory = computeCOPTrajectory(footData.leftFootData.frames);
reportData.rightTrajectory = computeCOPTrajectory(footData.rightFootData.frames);

reportData.intervalNum = (1:length(intervals)-1)';
% Compute  results as per intervals
reportData.meanContactAreaLeft = cellfun(@mean,splitVector(reportData.leftArea, footData.leftFootData.timeVect, intervals));
reportData.meanContactAreaRight = cellfun(@mean,splitVector(reportData.rightArea, footData.leftFootData.timeVect, intervals));

% Compute results as per intervals
reportData.meanFootForceLeft = cellfun(@mean,splitVector(reportData.leftWeight, footData.leftFootData.timeVect, intervals));
reportData.meanFootForceRight = cellfun(@mean,splitVector(reportData.rightWeight, footData.leftFootData.timeVect, intervals));

% Compute peak pressure as per intervals
reportData.peakPressureLeft = computeFootPPS(footData.leftFootData, intervals);
reportData.peakPressureRight = computeFootPPS(footData.rightFootData, intervals);

% Compute AP, PM, ML as per intervals
[reportData.leftAP, reportData.leftPM, reportData.leftML] = valentiniCOP(reportData.leftTrajectory, footData.leftFootData, intervals);
[reportData.rightAP, reportData.rightPM, reportData.rightML] = valentiniCOP(reportData.rightTrajectory, footData.rightFootData, intervals);
end