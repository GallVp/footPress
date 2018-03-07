function cop = computeCOP( inputFrame )
%computeCOP Finds the center of pressure as the centroid of the given
%   frame.
%
%   Inputs:
%   inputFrame is a 2D matrix with rows and columns of sensel values.
%
%   Outputs:
%   cop is a 1 by 2 vector containg x and y position of the center
%   of pressure.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.


% replace nans with zeros
inputFrame(isnan(inputFrame)) = 0;

nonzeroSensels = inputFrame ~= 0;
props = regionprops(double(nonzeroSensels), inputFrame, 'Centroid', 'WeightedCentroid');
cop = props.WeightedCentroid;
end