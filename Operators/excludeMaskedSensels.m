function outputFootData = excludeMaskedSensels(inputFootData, maskData)
%excludeMaskedSensels Excludes masked sensels.
%
%   Inputs:
%   inputFootData is a structure with following fields:
%       a. leftFootData
%       b. rightFootData
%       Both these variables are structures. See readFscanData.m
%   maskData is a structure with following variables:
%       a. leftMask, rightMask
%       Both these variables are 2D N by 3 matrices. N is the 
%       number of masked sensels. 1st column correspont to column
%       number, 2nd column corresponds to row number. And third
%       column is redundant and always has a zero value.
%
%   outputs:
%   outputFootData is a structure with following fields:
%       a. leftFootData
%       b. rightFootData
%       Both these variables are structures. See readFscanData.m
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

outputFootData = inputFootData;

if(~isempty(maskData))
    if(~isempty(maskData.leftMask))
        [m, n, o] = size(inputFootData.leftFootData.frames);
        lMask = zeros(m, n);
        lMask(sub2ind([m n], maskData.leftMask(:, 2), maskData.leftMask(:, 1))) = 1;
        lMask = lMask == 1;
        lMask = repmat(lMask, [1 1 o]);
        outputFootData.leftFootData.frames(lMask) = 0;
    end
    if(~isempty(maskData.rightMask))
        [m, n, o] = size(inputFootData.rightFootData.frames);
        rMask = zeros(m, n);
        rMask(sub2ind([m n], maskData.rightMask(:, 2), maskData.rightMask(:, 1))) = 1;
        rMask = rMask == 1;
        rMask = repmat(rMask, [1 1 o]);
        outputFootData.rightFootData.frames(rMask) = 0;
    end
end
end