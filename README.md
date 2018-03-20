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