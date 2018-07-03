function [ fHandle, areaL, areaR ] = plotFootArea( leftFootData, rightFootData, figTitle)
%plotFootArea Plots foot area per frame.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.


fHandle = figure('Name', figTitle, 'NumberTitle', 'off');

areaL = computeFootArea(leftFootData);
areaR = computeFootArea(rightFootData);

% Plot left foot
plot(leftFootData.timeVect, areaL, 'LineWidth', 2);
% plot right foot
hold
plot(rightFootData.timeVect, areaR, 'LineWidth', 2);

xlabel('Time (s)');
ylabel('Contact area (mmSquared)');
legend({'Left Foot', 'Right Foot'}, 'Box', 'off');
end