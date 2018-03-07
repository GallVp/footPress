function copTrajectory = computeCOPTrajectory( inputFrames )
%computeCOPTrajectory Finds the center of pressure as the centroid
%   of all  the frames  and returns a matrix  in which columns are 
%   (x, y) coordinates and rows  correspond to frames. inputFrames
%   is a 3D matrix with sensel values across rows and columns, and 
%   frames across the third dimension.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.


numframes = size(inputFrames, 3);
copTrajectory = zeros(numframes, 2);    %x,y

for i = 1:numframes
    d = inputFrames(:, :, i);
    % replace nans with zeros
    d(isnan(d)) = 0;
    
    BW = d ~= 0;
    props = regionprops(double(BW), d, 'Centroid', 'WeightedCentroid');
    if(isempty(props))
        copTrajectory(i, :) = NaN;
    else
        copTrajectory(i, :) = round(props.WeightedCentroid);
    end
end

end

