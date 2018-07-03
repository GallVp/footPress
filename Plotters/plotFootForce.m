function [ fHandle, pbwForceLeft, pbwForceRight ] = plotFootForce( leftFootData, rightFootData, figTitle)
%plotFootForce Plots per frame foot force as percentage of body weight.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

fHandle = figure('Name', figTitle, 'NumberTitle', 'off');

[~, pbwForceLeft] = computeFootForce(leftFootData);
[~, pbwForceRight] = computeFootForce(rightFootData);

% Plot left foot
plot(leftFootData.timeVect, pbwForceLeft, 'LineWidth', 2);
% plot right foot
hold
plot(rightFootData.timeVect, pbwForceRight, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Percentage of BW (%)');
legend({'Left Foot', 'Right Foot'}, 'Box', 'off');
end