function H = barSpecial(data, labels)
%barSpecial Creates a bar graph using matlab bar plot and with
%   some added functionality. data is a 2D Matrix with values
%   across rows and variables across columns.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

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

