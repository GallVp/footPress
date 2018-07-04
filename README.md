# footPress

footPress is a MATLAB based toolbox which can be used for visualization and analysis of plantar pressure data.

## Compatibility
Currently footPress is being developed on macOS High Sierra, MATLAB 2017b.

## Installation
1. Clone the git repository using git. Or, download a compressed copy [here](https://codeload.github.com/GallVp/footPress/zip/master).
```
$ git clone https://github.com/GallVp/footPress
```
2. From MATLAB file explorer, enter the footPress folder by double clicking it. Type **footPress** in the MATLAB command window and hit enter to run.

## Supported Formats
1. F-scan exported *asf* files
2. MATLAB *mat* files

### File Naming
From the footPress GUI, data for both left and right foot saved in separate files can be imported by keeping the files in the same folder and selecting one of the files. The files should be named as **exampleL.asf** and **exampleR.asf**. This naming convention allows footPress to automatically load the file for the opposite foot.

## Overview
The main features of the toolbox include data visualisation, sensor masking, time series, center of pressure and multi-segment analysis along with report generation. The toolbox can be used with an intuitive graphical user interface (GUI) without working with the underlying code. However, a functional approach to code implementation ensures that the toolbox can be used as a set of independent functions and new functions can easily be added.

The main data scroll GUI of footPress along with some of the other plots produced by different operations:

[[https://github.com/GallVp/footPress/blob/master/Samples/overview.png|alt=overview_figure]]

## Third Party Libraries
footPress uses following third party libraries. The licenses for these libraries can be found next to source files in their respective libs/thirdpartlib folders.
1. `barwitherr` Copyright (c) 2014, Martina Callaghan. Source is available [here](https://au.mathworks.com/matlabcentral/fileexchange/30639-barwitherr-errors-varargin-?focused=3845794&tab=function).