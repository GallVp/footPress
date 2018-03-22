function saveReport( fullFileName, reportData)
%saveReport A generic function which saves a MATLAB scalar
%   structure to a csv file. The only constraint is that all 
%   variables should be vectors. reportData is a MATLAB scalar 
%   structure.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

dlmwrite(fullFileName, '', 'delimiter', '');
varNames = fieldnames(reportData);
numVars = length(varNames);


for i = 1 : numVars
    dlmwrite(fullFileName, varNames{i}, '-append', 'delimiter','');
    dlmwrite(fullFileName, reportData.(varNames{i})', '-append',...
        'delimiter',',');
end
end