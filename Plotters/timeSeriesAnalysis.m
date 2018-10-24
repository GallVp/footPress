function timeSeriesAnalysis( footData,  intervals, maskData)
%timeSeriesAnalysis Plots a number of time series graphs for
%   the given
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
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.
if nargin < 3
    maskData = [];
end

% exclude masked data
footData = excludeMaskedSensels(footData, maskData);

% Plot weight as percentage of total body weight
[~, lWeight, rWeight] = plotFootForce(footData.leftFootData, footData.rightFootData, 'Foot force');

% Plot contact area
[~, lArea, rArea] = plotFootArea(footData.leftFootData, footData.rightFootData, 'Foot Area');


% Compute and plot results as per intervals
meanContactAreaL = cellfun(@mean,splitVector(lArea, footData.leftFootData.timeVect, intervals));
meanContactAreaR = cellfun(@mean,splitVector(rArea, footData.leftFootData.timeVect, intervals));

stdContactAreaL = cellfun(@std,splitVector(lArea, footData.leftFootData.timeVect, intervals));
stdContactAreaR = cellfun(@std,splitVector(rArea, footData.leftFootData.timeVect, intervals));

% Create interval labels
intervalLabels = cell(length(meanContactAreaL), 1);
for i=1:length(meanContactAreaL)
    intervalLabels{i} = sprintf('[%.3f %.3f]', intervals(i), intervals(i+1));
end

% Plot mean contact area per intervals
figure('Name', 'Mean Contact Area', 'NumberTitle', 'off');
barStat = [meanContactAreaL meanContactAreaR];
errStat = [stdContactAreaL stdContactAreaR];
barwitherrnn(errStat, barStat);
set(gca, 'Ticklength', [0 1]);
if(~isrow(barStat))
    xticklabels(intervalLabels);
    % Add time intervals
    xlabel('Interval Time (sec)');
    ylabel('Mean contact area (mm^{2})');
    legend({'Left Foot', 'Right Foot'}, 'Box', 'off');
    box off;
else
    xticklabels({'Left Foot', 'Right Foot'});
    % Add time intervals
    xlabel(sprintf('Interval Time: %s (sec)', intervalLabels{1}));
    ylabel('Mean contact area (mm^{2})');
    legend off;
    box off;
end

% Plot mean foot force per interval
% Compute and plot results as per time slices
meanFootForceL = cellfun(@mean,splitVector(lWeight, footData.leftFootData.timeVect, intervals));
meanFootForceR = cellfun(@mean,splitVector(rWeight, footData.leftFootData.timeVect, intervals));
stdFootForceL = cellfun(@std,splitVector(lWeight, footData.leftFootData.timeVect, intervals));
stdFootForceR = cellfun(@std,splitVector(rWeight, footData.leftFootData.timeVect, intervals));
figure('Name', 'Mean Foot Force', 'NumberTitle', 'off');

barStat = [meanFootForceL meanFootForceR];
errStat = [stdFootForceL stdFootForceR];
barwitherrnn(errStat, barStat);
set(gca, 'Ticklength', [0 1]);
if(~isrow(barStat))
    xticklabels(intervalLabels);
    % Add time interval points
    xlabel('Interval Time (sec)')
    ylabel('Percentage of BW (%)')
    legend({'Left Foot', 'Right Foot'}, 'Box', 'off');
    box off;
else
    xticklabels({'Left Foot', 'Right Foot'});
    % Add time intervals
    xlabel(sprintf('Interval Time: %s (sec)', intervalLabels{1}));
    ylabel('Percentage of BW (%)');
    legend off;
    box off;
end
% plot cop trajectory
copTrajectory.lTraj = computeCOPTrajectory(footData.leftFootData.frames);
copTrajectory.rTraj = computeCOPTrajectory(footData.rightFootData.frames);
hFig = figure('Name', 'COP Axis Analysis', 'NumberTitle', 'off');
axis ij;
axis([1 20 10 70])
pbaspect([1 3 1])
set(gca, 'XTick', []);
set(gca, 'YTick', []);
set(gca, 'LineWidth', 2);
% do the analysis
HL = copAxisAnalysis(hFig, copTrajectory.lTraj );
HR = copAxisAnalysis(hFig, copTrajectory.rTraj, 2 );
legend([HL HR], {'Left Foot', 'Right Foot'}, 'Box', 'off');
set(gca, 'XColor', [1 1 1]);
set(gca, 'YColor', [1 1 1]);
end