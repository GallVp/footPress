function outCell = splitVector(splittedVect, splittingVect, splitAt)
%splitVector Splits a vector along the third taking indices from
%   splittingVect and intervals defined by splitAt. outCell is a 
%   cell array of 3D matrices.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.


splittedVect = reshape(splittedVect, length(splittedVect), 1);
splittingVect = reshape(splittingVect, length(splittingVect), 1);
splitAt = reshape(splitAt, length(splitAt), 1);

outCell = cell(length(splitAt) - 1, 1);

for i = 2:length(splitAt)
    outCell{i - 1} = splittedVect(splittingVect >= splitAt(i-1) & splittingVect <= splitAt(i));
end
end