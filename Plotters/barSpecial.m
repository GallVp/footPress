function H = barSpecial(data, labels)
%barSpecial Creates a bar graph using matlab bar plot and with
%   some added functionality. data is a 2D Matrix with values
%   across rows and variables across columns.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

if(iscolumn(data))
    data = data';
end

% If data has only one row
if isrow(data)
    H = bar(vertcat(data,nan(size(data))));
    xlim([0.5 1.5]);
    xticklabels(labels);
else
    H = bar(data);
    xticklabels(labels);
end
end