function hObj = plotFootSegments( inputFrame, numSegments, unitNum, cellArea, bodyMass )
%plotFootSegments Splits and  plots pressure as  mean KPa or force
%   as percentage of body weight in each segment of a single frame
%   of data.
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
%   hObj is the handle of the MATLAB image object with frame 
%   segments drawn on it.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

COLOR_RANGE = [0 100];

[segmentedData, cents, pAns] = splitOperateSegment(inputFrame,...
    numSegments, unitNum, cellArea, bodyMass);

if(unitNum == 2)
    hObj = imagesc(segmentedData, COLOR_RANGE);
    colormap(jet);
    units = '%BW';
    % Add texts at the centre
    for i = 1:numSegments
        text(round(size(segmentedData,2) / 2), cents(i),...
            sprintf('%0.3f %s', pAns(i), units),...
            'FontSize', 15, 'FontWeight', 'Bold',...
            'HorizontalAlignment', 'center');
    end
else
    hObj = imagesc(segmentedData);
    colormap(jet);
    pAns = round(pAns);
    % Add texts at the centre
    units = 'KPa';
    for i = 1:numSegments
        text(round(size(segmentedData,2) / 2), cents(i), sprintf('%d %s', pAns(i), units),...
            'FontSize', 15, 'FontWeight', 'Bold', 'HorizontalAlignment', 'center');
    end
end
% Display nans as white
set(hObj,'alphadata', ~isnan(inputFrame));
end