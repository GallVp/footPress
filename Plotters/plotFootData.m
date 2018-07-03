function [outputData] = plotFootData(inputData, inputOptions)
%plotFootData A tool to plot pressure data.
%
%   Inputs:
%   inputData is a structure with following fields:
%       a. leftFootData
%       b. rightFootData
%   options is a structure with following fields:
%       a. modal is a scalar in [0/1]. If 1 the plot figure is modal.
%
%   Outputs:
%   outputData is an empty structure. To be used in future.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project
%   root for license information.

if nargin < 2
    inputOptions        = [];
end

%% Defalut values for optional parameters.
defaultOptions.modal    = 1;
vars.options            = assignOptions(inputOptions, defaultOptions);

%% Global Constants
% The constants should be all capital and declared as fields of
% 'vars' structure.
% This enlarge factor was added for the buttons at the bottom
vars.ENLARGE_FACTOR     = 75;
vars.HEIGHT_RATIO       = 0.8;
vars.WIDTH_RATIO        = 0.7;
vars.ON_OFF_CELL        = {'off', 'on'};

%% Global encapsulated variables
vars.inputData          = inputData;
vars.frameNum           = inputData.leftFootData.startFrame;
vars.lastFrameNum       = inputData.leftFootData.endFrame;
vars.totalFrameNum      = vars.lastFrameNum - vars.frameNum + 1;
vars.imageResFactor     = 1;
vars.intervalNum        = 1;
vars.totalIntervalNum   = 1;
vars.contourLevelNum    = 4;
vars.numSegments        = 3;
vars.segmentDataUnits   = 2; % 1 for KPa, 2 for %BW
vars.timeIntervals      = [inputData.leftFootData.timeVect(1) inputData.leftFootData.timeVect(end)];
vars.copDisplay         = 0; % 0 for no, 1 for cop, 2 for trajectory
vars.copTrajectory      = [];
vars.rightMask          = [];
vars.leftMask           = [];

% Flags for operations
vars.meanPressureFlag   = 0;
vars.peakPressureFlag   = 0;
vars.ptiFlag            = 0;
vars.splitFramesFlag    = 0;
vars.showContoursFlag   = 0;
vars.showSegmentsFlag   = 0;
vars.maskSensorsFlag    = 0;
vars.excludeSensorsFlag = 0;

%% Setup a plot window
% Instantiate the figure and define its size and orientation
H = figure('Visible',   'off',...
    'Units',            'pixels',...
    'ResizeFcn',        @handleResize,...
    'CloseRequestFcn',  @closeFigure,...
    'Name',             'plotFootData',...
    'numbertitle',      'off',...
    'KeyPressFcn',      @keyPressHandler,...
    'Color',            [1 1 1]);

% Add custom menues to the window
vars.pipesMenu = uimenu('Label','footPress');
vars.operationsMenu = uimenu(vars.pipesMenu,...
    'Label','Operators');
vars.optionsMenu = uimenu(vars.pipesMenu,...
    'Label','Options');
vars.timeSeriesMenu = uimenu(vars.pipesMenu,...
    'Label','Time series analysis',...
    'Callback',@timeSeries);

vars.generateReportMenu = uimenu(vars.pipesMenu,...
    'Label','Generate report',...
    'Callback',@generateReportCallback);
vars.resFactorMenu = uimenu(vars.optionsMenu,...
    'Label', 'Resolution factor',...
    'Callback', @setResFactor);
vars.splitFramesMenu = uimenu(vars.optionsMenu,...
    'Label','Split frames',...
    'Callback',@setSplitFrames,...
    'Enable', 'off',...
    'Checked', 'off',...
    'Separator', 'on');

vars.setIntervalsMenu = uimenu(vars.optionsMenu,...
    'Label','Set time intervals',...
    'Callback',@setTimeIntervals);

vars.showContoursMenu = uimenu(vars.optionsMenu,...
    'Label','Show contours',...
    'Callback',@showContours,...
    'Checked', 'off',...
    'Separator', 'on');

vars.setContourLevelsMenu = uimenu(vars.optionsMenu,...
    'Label','Set contour levels',...
    'Callback',@setContourLevels);

vars.showSegmentsMenu = uimenu(vars.optionsMenu,...
    'Label','Show segments',...
    'Callback',@showSegments,...
    'Checked', 'off',...
    'Separator', 'on');

vars.setNumSegmentMenu = uimenu(vars.optionsMenu,...
    'Label','Set segments number',...
    'Callback',@setNumSegments);

vars.setSegmentUnitsMenu = uimenu(vars.optionsMenu,...
    'Label','Set segment units',...
    'Callback',@setSegmentUnits);

vars.showCOPMenu = uimenu(vars.optionsMenu,...
    'Label','Show COP',...
    'Callback',@showCOP,...
    'Separator', 'on');
vars.showCOPTrajectoryMenu = uimenu(vars.optionsMenu,...
    'Label','Show COP trajectory',...
    'Callback',@showCOPTrajectory);

vars.maskSensorsMenu = uimenu(vars.optionsMenu,...
    'Label','Mask sensors',...
    'Callback',@maskSensors,...
    'Separator', 'on');
vars.importMaskMenu = uimenu(vars.optionsMenu,...
    'Label','Import mask',...
    'Callback',@importMask);
vars.exportMaskMenu = uimenu(vars.optionsMenu,...
    'Label','Export Mask',...
    'Callback',@exportMask);
vars.excludeSensorsMenu = uimenu(vars.optionsMenu,...
    'Label','Exclude sensors',...
    'Callback',@excludeSensors);

vars.peakPressureMenu = uimenu(vars.operationsMenu,...
    'Label','Peak pressure',...
    'Callback',@setPeakPressureFlag);
vars.meanPressureMenu = uimenu(vars.operationsMenu,...
    'Label','Mean pressure',...
    'Callback',@setMeanPressureFlag);
vars.ptiMenu = uimenu(vars.operationsMenu,...
    'Label','Pressure time integral',...
    'Callback',@setPtiFlag);

% Add push button for removing sensors

% Enlarge the figure to accomodate controls at the bottom
hPos = get(H, 'Position');
hPos(4) = hPos(4) + vars.ENLARGE_FACTOR;
hPos(2) = hPos(2) - vars.ENLARGE_FACTOR;
set(H, 'Position', hPos);

% Setup the window size according to available display size
set(0,'units','characters');
displayResolution = get(0,'screensize');

windowWidth = displayResolution(3) * vars.WIDTH_RATIO;
windowHeight = displayResolution(4) * vars.HEIGHT_RATIO;

windowXCent = (displayResolution(3) - windowWidth) / 2;
windowYCent = (displayResolution(4) - windowHeight) / 2;
set(H,'units','characters');
windowPosition = [windowXCent windowYCent windowWidth windowHeight];
set(H, 'pos', windowPosition);

%% Create ui controls
vars.txtFrameInfo = uicontrol(...
    'Style','text',...
    'Position',[125 50 150 20],...
    'HorizontalAlignment', 'left',...
    'FontSize', 14,...
    'BackgroundColor', [1 1 1]);

vars.txtIntervalInfo = uicontrol(...
    'Style','text',...
    'Position',[125 15 150 20],...
    'HorizontalAlignment', 'left',...
    'FontSize', 14,...
    'BackgroundColor', [1 1 1]);

vars.btnFirst = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'First',...
    'Position', [280 50 50 20],...
    'Callback', @first,...
    'FontSize', 14);

vars.btnPrevious = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'Prev.',...
    'Position', [355 50 50 20],...
    'Callback', @previous,...
    'FontSize', 14);

vars.btnNext = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'Next',...
    'Position', [430 50 50 20],...
    'Callback', @next,...
    'FontSize', 14);

vars.btnLast = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'Last',...
    'Position', [505 50 50 20],...
    'Callback', @last,...
    'FontSize', 14);

vars.sldFramePos = uicontrol(...
    'Style', 'slider',...
    'Min', vars.frameNum,...
    'Max', vars.lastFrameNum,...
    'Value', vars.frameNum,...
    'SliderStep', [1/(vars.totalFrameNum - 1) 2/(vars.totalFrameNum - 1)],...
    'Position', [600 50 200 17],...
    'Callback', @moveFrame,...
    'FontSize', 14);

vars.btnPreviousInterval = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'Prev.',...
    'Position', [355 15 50 20],...
    'Callback', @previousInterval,...
    'FontSize', 14);

vars.btnNextInterval = uicontrol(...
    'Style', 'pushbutton',...
    'String', 'Next',...
    'Position', [430 15 50 20],...
    'Callback', @nextInterval,...
    'FontSize', 14);

%% Initial display
% Make figure visible after adding all components and updating the view.
% Pause for user interaction
processData
updateView
set(H, 'Visible','on');
if(vars.options.modal == 1)
    uiwait(H);
end

%% Callbacks
    function next(~,~)
        vars.frameNum = vars.frameNum + 1;
        processData(0);
        updateView
    end

    function previous(~,~)
        vars.frameNum = vars.frameNum - 1;
        processData(0);
        updateView
    end

    function nextInterval(~,~)
        vars.intervalNum = vars.intervalNum + 1;
        processData
        updateView
    end

    function previousInterval(~,~)
        vars.intervalNum = vars.intervalNum - 1;
        processData
        updateView
    end

    function first(~,~)
        vars.frameNum = 1;
        processData(0);
        updateView
    end

    function last(~,~)
        vars.frameNum = vars.totalFrameNum;
        processData(0);
        updateView
    end

    function moveFrame(~,~)
        vars.frameNum = round(get(vars.sldFramePos, 'Value'));
        processData(0);
        updateView
    end

    function handleResize(~,~)
        updateView
    end

    function closeFigure(~,~)
        outputData = [];
        delete(gcf);
    end

    function keyPressHandler(~, eventData)
        if(strcmp(eventData.Key, 'rightarrow') && vars.frameNum < vars.lastFrameNum)
            vars.frameNum = vars.frameNum + 1;
            processData(0);
            updateView;
        end
        if(strcmp(eventData.Key, 'leftarrow') && vars.frameNum > 1)
            vars.frameNum = vars.frameNum - 1;
            processData(0);
            updateView;
        end
        
    end

    function setResFactor(~, ~)
        prompt={'Enter a resolution factor:'};
        name = 'Resolution Factor';
        defaultans = {num2str(vars.imageResFactor)};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        if(~isempty(answer))
            res = str2double(answer);
            if(res > 0)
                vars.imageResFactor = res;
                processData;
                updateView;
            end
        end
    end

    function setMeanPressureFlag(~, ~)
        if(vars.meanPressureFlag)
            vars.meanPressureFlag = 0;
            vars.peakPressureFlag = 0;
            vars.ptiFlag = 0;
        else
            vars.meanPressureFlag = 1;
            vars.peakPressureFlag = 0;
            vars.ptiFlag = 0;
        end
        processData;
        updateView;
    end
    function setPeakPressureFlag(~, ~)
        if(vars.peakPressureFlag)
            vars.meanPressureFlag = 0;
            vars.peakPressureFlag = 0;
            vars.ptiFlag = 0;
        else
            vars.meanPressureFlag = 0;
            vars.peakPressureFlag = 1;
            vars.ptiFlag = 0;
        end
        processData;
        updateView;
    end
    function setPtiFlag(~, ~)
        if(vars.ptiFlag)
            vars.meanPressureFlag = 0;
            vars.peakPressureFlag = 0;
            vars.ptiFlag = 0;
        else
            vars.meanPressureFlag = 0;
            vars.peakPressureFlag = 0;
            vars.ptiFlag = 1;
        end
        processData;
        updateView;
    end
    function setSplitFrames(~, ~)
        if(vars.splitFramesFlag)
            vars.splitFramesFlag = 0;
        else
            vars.splitFramesFlag = 1;
        end
        processData;
        updateView;
    end

    function showContours(~, ~)
        if(vars.showContoursFlag)
            vars.showContoursFlag = 0;
            vars.showSegmentsFlag = 0;
        else
            vars.showContoursFlag = 1;
            vars.showSegmentsFlag = 0;
        end
        updateView;
    end

    function setContourLevels(~, ~)
        prompt={'Enter number of contour levels:'};
        name = 'Contour levels';
        defaultans = {num2str(vars.contourLevelNum)};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        if(~isempty(answer))
            res = round(str2double(answer));
            if(res > 0)
                vars.contourLevelNum = res;
                updateView;
            end
        end
    end

    function showSegments(~, ~)
        if(vars.showSegmentsFlag)
            vars.showSegmentsFlag = 0;
            vars.showContoursFlag = 0;
        else
            vars.showSegmentsFlag = 1;
            vars.showContoursFlag = 0;
        end
        updateView;
    end

    function setNumSegments(~, ~)
        prompt={'Enter number of segments:'};
        name = 'Number of Segments';
        defaultans = {num2str(vars.numSegments)};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        if(~isempty(answer))
            res = round(str2double(answer));
            if(res > 0)
                vars.numSegments = res;
                updateView;
            end
        end
    end

    function setSegmentUnits(~, ~)
        str = {'KPa', '%BW'};
        [s,v] = listdlg('PromptString','Select units:',...
            'SelectionMode','single',...
            'ListString',str,...
            'InitialValue', vars.segmentDataUnits);
        if(v)
            vars.segmentDataUnits = s;
            updateView;
        end
    end

    function timeSeries(~, ~)
        if(vars.excludeSensorsFlag)
            maskData.leftMask = vars.leftMask;
            maskData.rightMask = vars.rightMask;
            timeSeriesAnalysis( vars.inputData, vars.timeIntervals, maskData);
        else
            timeSeriesAnalysis( vars.inputData, vars.timeIntervals);
        end
    end

    function setTimeIntervals(~, ~)
        prompt={'Enter time intervals:'};
        name = 'Time Intervals';
        defaultans = {num2str(vars.timeIntervals, 3)};
        answer = inputdlg(prompt,name,[1 40],defaultans);
        if(~isempty(answer))
            res = str2num(answer{:});
            vars.timeIntervals = res;
            vars.totalIntervalNum = length(vars.timeIntervals) - 1;
            processData;
            updateView;
        end
    end

    function showCOP(~, ~)
        if(vars.copDisplay == 1)
            vars.copDisplay = 0;
        else
            vars.copDisplay = 1;
        end
        processData;
        updateView;
    end

    function showCOPTrajectory(~, ~)
        if(vars.copDisplay == 2)
            vars.copDisplay = 0;
        else
            vars.copDisplay = 2;
        end
        processData;
        updateView;
    end
    function maskSensors(~, ~)
        if(vars.maskSensorsFlag)
            vars.maskSensorsFlag = 0;
        else
            vars.maskSensorsFlag = 1;
            vars.imageResFactor = 1;
        end
        processData;
        updateView;
    end

    function excludeSensors(~, ~)
        if(vars.excludeSensorsFlag)
            vars.excludeSensorsFlag = 0;
        else
            vars.excludeSensorsFlag = 1;
        end
        processData;
        updateView;
    end

    function leftFrameClicked(~, clickData)
        point = round(clickData.IntersectionPoint);
        % check if point already present
        if(~isempty(vars.leftMask))
            present = vars.leftMask == point;
            present = find(present(:, 1) & present(:, 2) & present(:, 3), 1);
        else
            present = [];
        end
        if(isempty(present))
            vars.leftMask = [vars.leftMask; point];
            
        else
            vars.leftMask(present, :) = [];
        end
        processData;
        updateView;
    end
    function rightFrameClicked(~, clickData)
        point = round(clickData.IntersectionPoint);
        % check if point already present
        if(~isempty(vars.rightMask))
            present = vars.rightMask == point;
            present = find(present(:, 1) & present(:, 2) & present(:, 3), 1);
        else
            present = [];
        end
        if(isempty(present))
            vars.rightMask = [vars.rightMask; point];
            
        else
            vars.rightMask(present, :) = [];
        end
        processData;
        updateView;
    end
    function exportMask(~, ~)
        leftMask = vars.leftMask;
        rightMask = vars.rightMask;
        uisave({'leftMask', 'rightMask'});
    end
    function importMask(~, ~)
        [fileName, pathName] = uigetfile('*.mat','Select the mask file');
        if(fileName)
            d = load(fullfile(pathName, fileName));
            if(~isempty(d.leftMask) || ~isempty(d.rightMask))
                vars.leftMask = d.leftMask;
                vars.rightMask = d.rightMask;
                vars.maskSensorsFlag = 1;
                vars.excludeSensorsFlag = 1;
                processData;
                updateView;
            end
        end
    end
    function generateReportCallback(~,~)
        [file,path] = uiputfile('report.csv','Name of report file');
        if(file)
            if(vars.excludeSensorsFlag)
                maskData.leftMask = vars.leftMask;
                maskData.rightMask = vars.rightMask;
                reportData = generateReport( vars.inputData, vars.timeIntervals, maskData);
            else
                reportData = generateReport( vars.inputData, vars.timeIntervals);
            end
            saveReport(fullfile(path, file), reportData);
        end
    end

%% Update view function
    function updateView
        % Setup the axis
        ax1 = subplot(1, 2, 1, 'Units', 'pixels', 'ButtonDownFcn', @leftFrameClicked);
        
        % Plot the data
        if(vars.showContoursFlag)
            [C, h] = contourf(vars.processedData.leftFrame(end:-1:1, :), vars.contourLevelNum, 'LineWidth', 2);
            h.LevelList = round(h.LevelList);
            clabel(C, h, 'FontSize', 15, 'LabelSpacing', 1000);
            % Display zeros as white
            colormap(ax1, jet);
            cMap = colormap(ax1);
            cMap(1, :) = [1, 1, 1];
            colormap(ax1, cMap);
        elseif(vars.showSegmentsFlag)
            imscLH = plotFootSegments( vars.processedData.leftFrame, vars.numSegments,...
                vars.segmentDataUnits, vars.processedData.cellArea,...
                vars.processedData.bodyMass );
        else
            % Resize image for display
            vars.processedData.leftFrame = imresize(vars.processedData.leftFrame, vars.imageResFactor);
            imscLH = imagesc(vars.processedData.leftFrame, [0 255]);
            if(vars.copDisplay == 1)
                hold on
                plot(vars.copTrajectory.lTraj(1) * vars.imageResFactor,...
                    vars.copTrajectory.lTraj(2) * vars.imageResFactor,...
                    'r*', 'MarkerSize', 15, 'linewidth', 2);
                hold off
            elseif(vars.copDisplay == 2)
                hold on
                plot(vars.copTrajectory.lTraj(1:vars.frameNum, 1) .* vars.imageResFactor,...
                    vars.copTrajectory.lTraj(1:vars.frameNum, 2) * vars.imageResFactor,...
                    '.-k', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'linewidth', 2);
                plot(vars.copTrajectory.lTraj(vars.frameNum, 1) * vars.imageResFactor,...
                    vars.copTrajectory.lTraj(vars.frameNum, 2) * vars.imageResFactor,...
                    'r*', 'MarkerSize', 15, 'linewidth', 2);
                hold off
            end
            % Display nans as white
            set(imscLH,'alphadata', ~isnan(vars.processedData.leftFrame));
            % Display zeros as white
            colormap(ax1, jet);
            cMap = colormap(ax1);
            cMap(1, :) = [1, 1, 1];
            colormap(ax1, cMap);
            
            if(vars.maskSensorsFlag)
                set(imscLH,  'ButtonDownFcn', @leftFrameClicked);
                for i=1:size(vars.leftMask, 1)
                    hold on
                    plot(ax1, vars.leftMask(i, 1), vars.leftMask(i, 2), 'sr', 'LineWidth', 2, 'MarkerSize', 10, 'ButtonDownFcn', @leftFrameClicked);
                    hold off
                end
            else
                set(imscLH,  'ButtonDownFcn', '');
            end
        end
        axis image
        
        
        
        % Make the axis smaller
        pos = get(ax1, 'Position');
        pos(2) = pos(2) + vars.ENLARGE_FACTOR / 2;
        pos(4) = pos(4) - vars.ENLARGE_FACTOR / 3;
        set(ax1, 'Position', pos);
        
        % Remove axis ticks
        set(ax1, 'XTick', []);
        set(ax1, 'YTick', []);
        
        % Add title
        title('Left Foot', 'FontSize', 14);
        box off;
        set(gca, 'LineWidth', 2);
        % plot the right frame
        ax2 = subplot(1, 2, 2, 'Units', 'pixels');
        
        % Plot the data
        if(vars.showContoursFlag)
            [C, h] = contourf(vars.processedData.rightFrame(end:-1:1, :), vars.contourLevelNum, 'LineWidth', 2);
            h.LevelList = round(h.LevelList);
            clabel(C, h, 'FontSize', 15, 'LabelSpacing', 1000);
            %Display zeros as white
            colormap(ax2, 'jet');
            cMap = colormap(ax2);
            cMap(1, :) = [1, 1, 1];
            colormap(ax2, cMap);
        elseif(vars.showSegmentsFlag)
            imscRH = plotFootSegments( vars.processedData.rightFrame, vars.numSegments,...
                vars.segmentDataUnits, vars.processedData.cellArea,...
                vars.processedData.bodyMass );
        else
            % Resize image for display
            vars.processedData.rightFrame = imresize(vars.processedData.rightFrame, vars.imageResFactor);
            imscRH = imagesc(vars.processedData.rightFrame, [0 255]);
            if(vars.copDisplay == 1)
                hold on
                plot(vars.copTrajectory.rTraj(1) * vars.imageResFactor,...
                    vars.copTrajectory.rTraj(2) * vars.imageResFactor,...
                    'r*', 'MarkerSize', 15, 'linewidth', 2);
                hold off
            elseif(vars.copDisplay == 2)
                hold on
                plot(vars.copTrajectory.rTraj(1:vars.frameNum, 1) .* vars.imageResFactor,...
                    vars.copTrajectory.rTraj(1:vars.frameNum, 2) * vars.imageResFactor,...
                    '.-k', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'linewidth', 2);
                plot(vars.copTrajectory.rTraj(vars.frameNum, 1) * vars.imageResFactor,...
                    vars.copTrajectory.rTraj(vars.frameNum, 2) * vars.imageResFactor,...
                    'r*', 'MarkerSize', 15, 'linewidth', 2);
                hold off
            end
            % Display nans as white
            set(imscRH,'alphadata', ~isnan(vars.processedData.rightFrame));
            %Display zeros as white
            colormap(ax2, 'jet');
            cMap = colormap(ax2);
            cMap(1, :) = [1, 1, 1];
            colormap(ax2, cMap);
            if(vars.maskSensorsFlag)
                set(imscRH,  'ButtonDownFcn', @rightFrameClicked);
                for i=1:size(vars.rightMask, 1)
                    hold on
                    plot(ax2, vars.rightMask(i, 1), vars.rightMask(i, 2), 'sr', 'LineWidth', 2, 'MarkerSize', 10, 'ButtonDownFcn', @rightFrameClicked);
                    hold off
                end
            else
                set(imscRH,  'ButtonDownFcn', '');
            end
        end
        
        axis image
        
        % Make the axis smaller
        pos = get(ax2, 'Position');
        pos(2) = pos(2) + vars.ENLARGE_FACTOR / 2;
        pos(4) = pos(4) - vars.ENLARGE_FACTOR / 3;
        set(ax2, 'Position', pos);
        
        % Remove axis ticks
        set(ax2, 'XTick', []);
        set(ax2, 'YTick', []);
        
        % Add title
        title('Right Foot', 'FontSize', 14);
        
        
        % Update controls view
        
        % Enable disable frame controls
        if(vars.frameNum == vars.lastFrameNum)
            set(vars.btnNext, 'Enable', 'off');
            set(vars.btnLast, 'Enable', 'off');
        else
            set(vars.btnNext, 'Enable', 'on');
            set(vars.btnLast, 'Enable', 'on');
        end
        if(vars.frameNum == 1)
            set(vars.btnPrevious, 'Enable', 'off');
            set(vars.btnFirst, 'Enable', 'off');
        else
            set(vars.btnPrevious, 'Enable', 'on');
            set(vars.btnFirst, 'Enable', 'on');
        end
        
        % Set slider value
        set(vars.sldFramePos, 'Value', vars.frameNum);
        
        % Set operations check boxes
        set(vars.peakPressureMenu, 'Checked', vars.ON_OFF_CELL{vars.peakPressureFlag + 1});
        set(vars.meanPressureMenu, 'Checked', vars.ON_OFF_CELL{vars.meanPressureFlag + 1});
        set(vars.ptiMenu, 'Checked', vars.ON_OFF_CELL{vars.ptiFlag + 1});
        
        % Disable controls in case of operations
        if(vars.meanPressureFlag || vars.peakPressureFlag || vars.ptiFlag)
            set(vars.sldFramePos, 'Enable', 'off');
            set(vars.btnPrevious, 'Enable', 'off');
            set(vars.btnFirst, 'Enable', 'off');
            set(vars.btnNext, 'Enable', 'off');
            set(vars.btnLast, 'Enable', 'off');
            
            % Set frame info
            if(vars.meanPressureFlag)
                set(vars.txtFrameInfo, 'String', 'Mean Pressure');
            elseif(vars.peakPressureFlag)
                set(vars.txtFrameInfo, 'String', 'Peak Pressure');
            elseif(vars.ptiFlag)
                set(vars.txtFrameInfo, 'String', 'PTI');
            end
        else
            set(vars.sldFramePos, 'Enable', 'on');
            % Set frame info
            set(vars.txtFrameInfo, 'String', sprintf('Frame No: %d/%d', vars.frameNum, vars.totalFrameNum));
        end
        
        % Display selected interval info
        if(vars.splitFramesFlag)
            set(vars.txtIntervalInfo, 'String', sprintf('Interval No: %d/%d', vars.intervalNum, vars.totalIntervalNum));
            set(vars.txtIntervalInfo, 'Visible', 'on');
            set(vars.btnPreviousInterval, 'Visible', 'on');
            set(vars.btnNextInterval, 'Visible', 'on');
            set(vars.sldFramePos,...
                'Min', 1,...
                'Max', vars.totalFrameNum,...
                'Value', vars.frameNum,...
                'SliderStep', [1/(vars.totalFrameNum - 1) 2/(vars.totalFrameNum - 1)]);
        else
            set(vars.txtIntervalInfo, 'Visible', 'off');
            set(vars.btnPreviousInterval, 'Visible', 'off');
            set(vars.btnNextInterval, 'Visible', 'off');
            set(vars.sldFramePos,...
                'Min', 1,...
                'Max', vars.totalFrameNum,...
                'Value', vars.frameNum,...
                'SliderStep', [1/(vars.totalFrameNum - 1) 2/(vars.totalFrameNum - 1)]);
        end
        % Set enable of split frames menu item
        if(vars.totalIntervalNum >= 2)
            set(vars.splitFramesMenu, 'Checked', vars.ON_OFF_CELL{vars.splitFramesFlag + 1});
            set(vars.splitFramesMenu, 'Enable', 'on');
        else
            set(vars.splitFramesMenu, 'Checked', vars.ON_OFF_CELL{vars.splitFramesFlag + 1});
            set(vars.splitFramesMenu, 'Enable', 'off');
        end
        
        % Set enable of next previous interval buttons
        if(vars.intervalNum == vars.totalIntervalNum)
            set(vars.btnNextInterval, 'Enable', 'off');
        else
            set(vars.btnNextInterval, 'Enable', 'on');
        end
        if(vars.intervalNum == 1)
            set(vars.btnPreviousInterval, 'Enable', 'off');
        else
            set(vars.btnPreviousInterval, 'Enable', 'on');
        end
        
        % Set check status of show contours menu
        set(vars.showContoursMenu, 'Checked', vars.ON_OFF_CELL{vars.showContoursFlag + 1});
        
        % Set check status of show segments menu
        set(vars.showSegmentsMenu, 'Checked', vars.ON_OFF_CELL{vars.showSegmentsFlag + 1});
        
        % Set check status of cop and cop trajectory menus
        if(vars.copDisplay == 0)
            set(vars.showCOPMenu, 'Checked', 'off');
            set(vars.showCOPTrajectoryMenu, 'Checked', 'off');
        elseif(vars.copDisplay == 1)
            set(vars.showCOPMenu, 'Checked', 'on');
            set(vars.showCOPTrajectoryMenu, 'Checked', 'off');
        else
            set(vars.showCOPMenu, 'Checked', 'off');
            set(vars.showCOPTrajectoryMenu, 'Checked', 'on');
        end
        
        % Set check status of maskSensorsMenu
        set(vars.maskSensorsMenu, 'Checked', vars.ON_OFF_CELL{vars.maskSensorsFlag + 1});
        set(vars.resFactorMenu, 'Enable', vars.ON_OFF_CELL{2 - vars.maskSensorsFlag});
        
        
        % Set check and enable status of maskSensorsMenu
        set(vars.excludeSensorsMenu, 'Checked', vars.ON_OFF_CELL{vars.excludeSensorsFlag + 1});
        if(~isempty(vars.rightMask) || ~isempty(vars.leftMask))
            set(vars.excludeSensorsMenu, 'Enable', 'on');
            set(vars.exportMaskMenu, 'Enable', 'on');
        else
            set(vars.excludeSensorsMenu, 'Enable', 'off');
            set(vars.exportMaskMenu, 'Enable', 'off');
        end
        box off;
        set(gca, 'LineWidth', 2);
    end

%% Processed data function
    function processData(updateCOPTrajectory)
        if nargin < 1
            updateCOPTrajectory = 1;
        end
        % Get and split data
        if(vars.splitFramesFlag)
            vars.processedData.leftFrames = split3DMat(vars.inputData.leftFootData.frames,...
                vars.inputData.leftFootData.timeVect, vars.timeIntervals);
            vars.processedData.leftFrames = vars.processedData.leftFrames{vars.intervalNum};
            vars.processedData.rightFrames = split3DMat(vars.inputData.rightFootData.frames,...
                vars.inputData.rightFootData.timeVect, vars.timeIntervals);
            vars.processedData.rightFrames = vars.processedData.rightFrames{vars.intervalNum};
            vars.totalFrameNum = size(vars.processedData.rightFrames, 3);
            if(vars.frameNum > vars.totalFrameNum)
                vars.frameNum = 1;
            end
        else
            if(vars.totalIntervalNum <= 1)
                selectedFrames = round((vars.timeIntervals(1)...
                    :1/vars.inputData.leftFootData.frameRate: vars.timeIntervals(end))...
                    .* vars.inputData.leftFootData.frameRate);
                vars.processedData.leftFrames = vars.inputData.leftFootData.frames(:,:,selectedFrames);
                vars.processedData.rightFrames = vars.inputData.rightFootData.frames(:,:,selectedFrames);
                vars.totalFrameNum = size(vars.processedData.leftFrames, 3);
                if(vars.frameNum > vars.totalFrameNum)
                    vars.frameNum = 1;
                end
            else
                vars.processedData.leftFrames = vars.inputData.leftFootData.frames;
                vars.processedData.rightFrames = vars.inputData.rightFootData.frames;
                vars.totalFrameNum = size(vars.processedData.leftFrames, 3);
                if(vars.frameNum > vars.totalFrameNum)
                    vars.frameNum = 1;
                end
            end
        end
        
        % Get data units, area and bodymass
        vars.processedData.units = vars.inputData.leftFootData.units;
        vars.processedData.bodyMass = vars.inputData.leftFootData.bodyMass;
        vars.processedData.cellArea = vars.inputData.leftFootData.colSpacing * vars.inputData.leftFootData.rowSpacing;
        
        % Exclude sensors if need be
        if(vars.excludeSensorsFlag)
            if(~isempty(vars.leftMask))
                [m, n, o] = size(vars.processedData.leftFrames);
                lMask = zeros(m, n);
                lMask(sub2ind([m n], vars.leftMask(:, 2), vars.leftMask(:, 1))) = 1;
                lMask = lMask == 1;
                lMask = repmat(lMask, [1 1 o]);
                vars.processedData.leftFrames(lMask) = 0;
            end
            if(~isempty(vars.rightMask))
                [m, n, o] = size(vars.processedData.rightFrames);
                rMask = zeros(m, n);
                rMask(sub2ind([m n], vars.rightMask(:, 2), vars.rightMask(:, 1))) = 1;
                rMask = rMask == 1;
                rMask = repmat(rMask, [1 1 o]);
                vars.processedData.rightFrames(rMask) = 0;
            end
        end
        
        % compute cop trajectory
        if(vars.copDisplay == 1)
            vars.copTrajectory.lTraj = computeCOPTrajectory(vars.processedData.leftFrames(:,:,vars.frameNum));
            vars.copTrajectory.rTraj = computeCOPTrajectory(vars.processedData.rightFrames(:,:,vars.frameNum));
        elseif(vars.copDisplay == 2 && updateCOPTrajectory == 1)
            vars.copTrajectory.lTraj = computeCOPTrajectory(vars.processedData.leftFrames);
            vars.copTrajectory.rTraj = computeCOPTrajectory(vars.processedData.rightFrames);
        end
        
        % Perform pressure calculation operations
        if(vars.meanPressureFlag)
            vars.processedData.leftFrame = mean(vars.processedData.leftFrames, 3);
            vars.processedData.rightFrame = mean(vars.processedData.rightFrames, 3);
        elseif(vars.peakPressureFlag)
            vars.processedData.leftFrame = max(vars.processedData.leftFrames,[], 3);
            vars.processedData.rightFrame = max(vars.processedData.rightFrames,[], 3);
        elseif(vars.ptiFlag)
            vars.processedData.leftFrame = sum(vars.processedData.leftFrames, 3)...
                ./ vars.inputData.leftFootData.frameRate;
            vars.processedData.rightFrame = sum(vars.processedData.rightFrames, 3)...
                ./ vars.inputData.rightFootData.frameRate;
        else
            vars.processedData.leftFrame = vars.processedData.leftFrames(:, :, vars.frameNum);
            vars.processedData.rightFrame = vars.processedData.rightFrames(:, :, vars.frameNum);
        end
    end
end