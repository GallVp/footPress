function [ segmentedFrame, centres, opAns ] = splitOperateSegment( inputFrame, numSegments, unitNum, cellArea, bodyMass )
%splitOperateSegment Splits a frame into segments and finds mean Kpa or
%   force as percentage of body weight in that segment.
%
%   Inputs:
%   inputFrame is a 2D matrix with sensel values across rows and
%   columns.
%   numSegments is the number of segments in which to divide the
%   frame.
%   unitNum is a scalar in [1/2]. 1 for mean Kpa. And 2 for %BW.
%   cellArea is the area of a sensel in meter squared.
%   bodyMass is the weight of a person in kilograms (Kg).
%
%   Outputs:
%   segmentedFrame is a 2D matrix with result values across rows 
%   and columns.
%   centres is a vector with row numbers which corresponds to the
%   centre rows of the segemts.
%   opAns is a vector with answers of applied operation for each 
%   segment.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

% 1000 as pressure units are assumed to be KPa, 9.8 m/s gravitational 
% accelration and 100 for percentage.
KPA_TO_PA_FACTOR    = 1000;
GRAVITATIONAL_ACCEL = 9.8;% m/s
PERCENTAGE_FACTOR   = 100;

numRows = size(inputFrame, 1);
rowsPerSegment = floor(numRows / numSegments);

segmentedFrame = zeros(size(inputFrame));
centres = zeros(numSegments, 1);
opAns = zeros(numSegments, 1);

for i=1:numSegments
    selectedIndices = 1 + rowsPerSegment * (i - 1) : rowsPerSegment * i;
    centres(i) = selectedIndices(round(length(selectedIndices) /2));
    if(unitNum == 2)
        opAns(i) = nansum(nansum(inputFrame(selectedIndices,:)));
        
        opAns(i) = opAns(i) .* KPA_TO_PA_FACTOR .* cellArea ./ bodyMass ./ GRAVITATIONAL_ACCEL .* PERCENTAGE_FACTOR;
    else
        opAns(i) = nansum(nansum(inputFrame(selectedIndices,:)));
        n = sum(sum(~isnan(inputFrame(selectedIndices,:)) & inputFrame(selectedIndices,:) ~=0));
        opAns(i) = opAns(i) / n;
    end
    segmentedFrame(selectedIndices,:) = opAns(i);
end
segmentedFrame(isnan(inputFrame)) = nan;
end