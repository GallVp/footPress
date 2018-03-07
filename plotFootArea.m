function [ fHandle, areaL, areaR ] = plotFootArea( leftFootData, rightFootData, figTitle)
%plotFootArea Plots foot area per frame.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.


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

