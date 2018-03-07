function saveReport( fullFileName, reportData)
%saveReport A generic function which saves a MATLAB scalar
%   structure to a csv file. The only constraint is that all 
%   variables should be vectors. reportData is a MATLAB scalar 
%   structure.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

dlmwrite(fullFileName, '', 'delimiter', '');
varNames = fieldnames(reportData);
numVars = length(varNames);


for i = 1 : numVars
    dlmwrite(fullFileName, varNames{i}, '-append', 'delimiter','');
    dlmwrite(fullFileName, reportData.(varNames{i})', '-append',...
        'delimiter',',');
end
end

