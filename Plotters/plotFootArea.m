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
plot(leftFootData.timeVect, areaL)
% plot right foot
hold
plot(rightFootData.timeVect, areaR)

title(leftFootData.comments)
xlabel('Time (s)')
ylabel('Contact area (mmSquared)')
legend('Left Foot', 'Right Foot')
end