function outCell = split3DMat(splittedMat, splittingVect, splitAt)
%split3DMat Splits a 3 dimensional matrix along the third 
%   dimension taking indices from splittingVect and intervals
%   defined by splitAt. outCell is a cell array of 3D matrices.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

splittingVect = reshape(splittingVect, length(splittingVect), 1);
splitAt = reshape(splitAt, length(splitAt), 1);

outCell = cell(length(splitAt) - 1, 1);

for i = 2:length(splitAt)
    outCell{i - 1} = splittedMat(:,:, splittingVect >= splitAt(i-1) & splittingVect <= splitAt(i));
end
end