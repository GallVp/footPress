function outCell = split3DMat(splittedMat, splittingVect, splitAt)
%split3DMat Splits a 3 dimensional matrix along the third 
%   dimension taking indices from splittingVect and intervals
%   defined by splitAt. outCell is a cell array of 3D matrices.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

splittingVect = reshape(splittingVect, length(splittingVect), 1);
splitAt = reshape(splitAt, length(splitAt), 1);

outCell = cell(length(splitAt) - 1, 1);

for i = 2:length(splitAt)
    outCell{i - 1} = splittedMat(:,:, splittingVect >= splitAt(i-1) & splittingVect <= splitAt(i));
end
end