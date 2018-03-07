function [ fHandle, pbwForceLeft, pbwForceRight ] = plotFootForce( leftFootData, rightFootData, figTitle)
%plotFootForce Plots per frame foot force as percentage of body weight.
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

[~, pbwForceLeft] = computeFootForce(leftFootData);
[~, pbwForceRight] = computeFootForce(rightFootData);

% Plot left foot
plot(leftFootData.timeVect, pbwForceLeft)
% plot right foot
hold
plot(rightFootData.timeVect, pbwForceRight)
title(leftFootData.comments)
xlabel('Time (s)')
ylabel('Percentage of BW (%)')
legend('Left Foot', 'Right Foot')
end