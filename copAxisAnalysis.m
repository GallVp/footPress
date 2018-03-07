function h = copAxisAnalysis(hFig, copTraj, colorSchemeNum )
%copAxisAnalysis Performs analysis using center of pressure
%   trajectory as described by <a
%   href="https://www1.udel.edu/biology/rosewc/kaap686/reserve/cop/center%20of%20pressure.html">UDEL/Biology</a>.
%   Code taken from above source with some suitable changes.
%
%   Inputs:
%   hFig is a handle to a matlab figure.
%   copTraj is a 2D matrix with frames across rows and x, y
%   coordinates across columns.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

if nargin < 3
    colorSchemeNum = 1;
end

% Two color schemes so that two feet with different color for markers can
% be plotted on the same figure.
if(colorSchemeNum == 1)
    cols    = {'r.', 'g', 'b'};
else
    cols    = {'c.', 'm', 'k'};
end

[m, n]      = size(copTraj);             % returns m = rows, n = columns of copTraj
meanCop     = nanmean(copTraj);          % returns row vector with column means of copTraj
covCop      = cov(copTraj, 'omitrows');  % covariance matrix for copTraj
[V,D]       = eig(covCop);               % V=eigenvectors, D=eigenvalues of covCop
semimaj     = [meanCop; meanCop+2.45*sqrt(D(1,1))*V(:,1)']; % center and end of semimajor axis

semimin     = [meanCop; meanCop+2.45*sqrt(D(2,2))*V(:,2)']; % center and end of semiminor axis

theta       = linspace(0, 2*pi, 100)';
ellipse     = 2.45*sqrt(D(1,1))*cos(theta)*V(:,1)' + 2.45*sqrt(D(2,2))*sin(theta)*V(:,2)' + ones(size(theta))*meanCop;
figure(hFig);
hold on
plot(copTraj(:,1), copTraj(:,2), cols{1}); % scatter plot with x = column 1 of copTraj, y = column 2
plot(semimaj(:,1), semimaj(:,2), cols{2}, 'LineWidth', 2);
plot(semimin(:,1), semimin(:,2), cols{2}, 'LineWidth', 2);
h = plot(ellipse(:,1), ellipse(:,2), cols{3}, 'LineWidth', 2);
hold off
end