function [ outputData ] = readFscanData( fileName )
%READFSCANDATA Reads F-scan data exported in *.asf file format.
%
%   Inputs:
%   fileName: Name of the file to read data from
%   
%   Outputs:
%   outputData is a structure with following fields:
%       a. numRows is the number of rows of sensels.
%       b. numColumns is the number of columns of sensels.
%       c. startFrame is the starting frame number.
%       d. endFrame is the ending frame number.
%       e. units is the units of pressure.
%       f. frameRate is the frame rate.
%       g. rowSpacing is spacing (in meters) betweeen the sensels
%          across rows.
%       h. rowSpacingUnits is the units of row spacing.
%       i. colSpacing is spacing (in meters) betweeen the sensels 
%          across columns.
%       j. colSpacingUnits is the units of column spacing.
%       k. satPressure is the saturation pressure.
%       l. bodyMass is the body mass.
%       m. comments are any comments added to the file.
%       n. frames is a 3-D matrix, with rows, cols for sensel
%          values and the third dimension for frames.
%       o. timeVect is a vector representing time points for the 
%          frames (in seconds).
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

readData = fileread(fileName);
expression = '(.*)ASCII_DATA @@(.*)';
fileData = regexp(readData, expression, 'tokens');
headerData = fileData{1,1}{1,1};
framesData = fileData{1,1}{1,2};

%% Read Header
% Get number of Rows
expression = 'ROWS ([0-9]*)';
numRows = regexp(headerData, expression, 'tokens');
outputData.numRows = str2double(numRows{:});

% Get number of Columns
expression = 'COLS ([0-9]*)';
numColumns = regexp(headerData, expression, 'tokens');
outputData.numColumns = str2double(numColumns{:});

% Get start frame number
expression = 'START_FRAME ([0-9]*)';
startFrame = regexp(headerData, expression, 'tokens');
outputData.startFrame = str2double(startFrame{:});

% Get end frame number
expression = 'END_FRAME ([0-9]*)';
endFrame = regexp(headerData, expression, 'tokens');
outputData.endFrame = str2double(endFrame{:});

% Get units
expression = 'UNITS ([a-zA-Z]*)';
units = regexp(headerData, expression, 'tokens');
outputData.units = units{:}{:};

% Get sampling rate
expression = 'SECONDS_PER_FRAME ([\.0-9]*)';
frameRate = regexp(headerData, expression, 'tokens');
outputData.frameRate = 1 / str2double(frameRate{:});

% Get row spacing
expression = 'ROW_SPACING ([\.0-9]*) ([A-Za-z]*)';
rowSpacing = regexp(headerData, expression, 'tokens');
outputData.rowSpacing = str2double(rowSpacing{:}{1});
outputData.rowSpacingUnits = rowSpacing{:}{2};

% Get column spacing
expression = 'COL_SPACING ([\.0-9]*) ([A-Za-z]*)';
colSpacing = regexp(headerData, expression, 'tokens');
outputData.colSpacing = str2double(colSpacing{:}{1});
outputData.colSpacingUnits = colSpacing{:}{2};

% Adjust colSpacing and rowSpacing according to units. The numbers should
% be in meters
if(strcmp(outputData.rowSpacingUnits, 'mm'))
    outputData.rowSpacing = outputData.rowSpacing / 1000;
    outputData.rowSpacingUnits = 'meters';
end
if(strcmp(outputData.colSpacingUnits, 'mm'))
    outputData.colSpacing = outputData.colSpacing / 1000;
    outputData.colSpacingUnits = 'meters';
end

% Get saturation pressure
expression = 'SATURATION_PRESSURE ([\.0-9]*)';
satPressure = regexp(headerData, expression, 'tokens');
outputData.satPressure = str2double(satPressure{:});

% Get person's mass
expression = 'CALIBRATION_POINT_1 ([\.0-9]*)';
bodyMass = regexp(headerData, expression, 'tokens');
if(isempty(bodyMass))
    outputData.bodyMass = [];
else
    outputData.bodyMass = str2double(bodyMass{:});
end

% Read comments
% Get units
expression = 'COMMENTS:[\s]*([^\r\n]*)';
comments = regexp(headerData, expression, 'tokens');
outputData.comments = strtrim(comments{:}{:});

%% Read frames
expression = 'Frame ([^\s]*)([0-9,B\s]*)';
frames = regexp(framesData, expression, 'tokens');


numFrames = size(frames, 2);
frameData = zeros(outputData.numRows, outputData.numColumns, numFrames);

for i = 1 : numFrames
    dat = frames{1,i}{1,2};
    dat = textscan(dat,'%f','Delimiter', ',', 'TreatAsEmpty', 'B', 'EmptyValue', NaN);
    dat = dat{:};
    frameData(:,:,i) = reshape(dat, outputData.numColumns, outputData.numRows)';
end
outputData.frames = frameData;
outputData.timeVect = (1/outputData.frameRate * outputData.startFrame):1/outputData.frameRate:(1/outputData.frameRate * outputData.endFrame);
end

