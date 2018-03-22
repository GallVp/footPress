function outCell = splitVector(splittedVect, splittingVect, splitAt)
%splitVector Splits a vector along the third taking indices from
%   splittingVect and intervals defined by splitAt. outCell is a 
%   cell array of 3D matrices.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.


splittedVect = reshape(splittedVect, length(splittedVect), 1);
splittingVect = reshape(splittingVect, length(splittingVect), 1);
splitAt = reshape(splitAt, length(splitAt), 1);

outCell = cell(length(splitAt) - 1, 1);

for i = 2:length(splitAt)
    outCell{i - 1} = splittedVect(splittingVect >= splitAt(i-1) & splittingVect <= splitAt(i));
end
end