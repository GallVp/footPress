function footPress
%footPress Opens a dialog to load and plot data
%
%
%   Copyright (c) <2018> <Usman Rashid>
%
%   This program is free software; you  can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation; either version 3 of
%   the License, or ( at your option ) any later version.  See the
%   LICENSE included with this distribution for more information.

% Global Variables encapsulated
vars.loadedData = [];
vars.intervals = [];

%% Setup a dialog
d = dialog('Name', 'footPress',...
    'CloseRequestFcn', @closeFigure,...
    'WindowStyle', 'normal');

% Set window size  according to following ratio
heightRatio = 0.2;
widthRatio = 0.4;

set(0,'units','characters');

displayResolution = get(0,'screensize');

dialogWidth = displayResolution(3) * widthRatio;
dialogHeight = displayResolution(4) * heightRatio;
dialogX = (displayResolution(3) - dialogWidth) / 2;
dialogY = (displayResolution(4) - dialogHeight) / 2;
set(d,'units','characters');
windowPosition = [dialogX dialogY dialogWidth dialogHeight];
set(d, 'pos', windowPosition);

set(d,'units','pixels');
dialogPos = get(d, 'pos');
dialogWidth = dialogPos(3);
dialogHeight = dialogPos(4);

% Control props
btnWidth = dialogWidth / 6;
btnHeight = dialogHeight / 4;
txtWidth = btnWidth * 2;

btnXSep = btnWidth * 1.2;
btnYSep = btnHeight * 1.2;

btnXPos = (dialogWidth - btnWidth) / 2;
btnYPos = (dialogHeight - btnHeight) / 2 - btnYSep;

txtXPos = (dialogWidth - txtWidth) / 2;

% Add controls
vars.txtDataInfo = uicontrol(d,...
    'Style', 'text',...
    'Position', [txtXPos btnYPos + 1.5 * btnYSep txtWidth btnHeight],...
    'String', 'Load data to begin...');

vars.btnLoadFile = uicontrol(d,...
    'Style', 'pushbutton',...
    'String', 'Load File',...
    'Position', [btnXPos - btnXSep btnYPos btnWidth btnHeight],...
    'Callback', @loadFile);

vars.btnPlotData = uicontrol(d,...
    'Style', 'pushbutton',...
    'String', 'Plot Data',...
    'Position', [btnXPos + btnXSep btnYPos btnWidth btnHeight],...
    'Callback', @plotData,...
    'Enable', 'off');



%% Callbacks
    function loadFile(~, ~)
        % Load file
        [fileName, pathName] = uigetfile('*.asf','Select an asf file');
        
        if(~fileName)
            return;
        end
        
        % Find out the side
        sideSuffix = strsplit(fileName, '.');
        sideSuffix = sideSuffix{1,1};
        sideSuffix = sideSuffix(end);
        
        switch sideSuffix
            case 'L'
                fullPathL = fullfile(pathName, fileName);
                fileName(end-4) = 'R';
                fullPathR = fullfile(pathName, fileName);
            case 'R'
                fullPathR = fullfile(pathName, fileName);
                fileName(end-4) = 'L';
                fullPathL = fullfile(pathName, fileName);
            otherwise
                return
        end
        
        vars.loadedData.leftFootData = readFscanData(fullPathL);
        vars.loadedData.rightFootData = readFscanData(fullPathR);
        vars.fileName = fileName;
        dataLoadedNotify;
    end

    function plotData(~, ~)
        % Plot raw data
        footData.leftFootData = vars.loadedData.leftFootData;
        footData.rightFootData = vars.loadedData.rightFootData;
        
        options.modal = 0;
        plotFootData(footData, options);
    end

    function closeFigure(~,~)
        close all FORCE;
    end

%% Update functions
    function dataLoadedNotify
        set(vars.btnPlotData, 'Enable', 'on');
        set(vars.txtDataInfo, 'String', sprintf('Loaded file(s): %s\n%s', vars.fileName,...
            vars.loadedData.leftFootData.comments));
    end
end