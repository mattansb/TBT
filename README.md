# TBT

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241519.svg)](https://doi.org/10.5281/zenodo.1241519)

This EEGLAB plugin allows for the automatic rejection and interpolation of channels on an epoch-by-epoch basis.

It also comes with an additional method for rejecting epochs - max-minus-min threshold.

## Downloading

- You can download TBT through EEGLAB's data-processing extension GUI (_File > Manage EEGLAB Extensions > Data-Processing Extensions_).
- Or as a `.zip` file from EEGLABS's servers [(TBT v1.5)](http://sccn.ucsd.edu/eeglab/plugins/TBT1.5.zip).
- Or as a `.zip` file from the GitHub page [(TBT v1.5)](https://github.com/mattansb/TBT/releases).

## Using `pop_TBT`
### List of included functions
- `eegplugin_TBT` - EEGLAB plugin function.
- `tbt_bcr` - epoch-by-epoch channel interpolation, based on any rejection method used by EEGLAB, or a manual cell-array listing which channels to interpolate in which epochs.
- `pop_TBT` - call from EEGLAB menu of `tbt_bcr`. If no parameters are specified, pops a GUI window

### TBT GUI

![pop_TBT](doc/TBT_eg.png)

### Scripting
```matlab
[EEG, com, badlist] = pop_TBT(EEG); % pop-up interactive window mode

EEG         		= pop_TBT(EEG,bads,badsegs,badchans,plot_bads);
% EEG         - input dataset
% bads        - a boolean 2-d matrix (channels * trials) specifying "bad
%               channels" for each epoch. OR
%               a x-by-2 cell list, with the first column specifying the
%               epochs, and the second column specifying the bad channels
%               in those epochs. e.g.: {1,{'E12'};[13 28],{'E22'}} will
%               remove E12 from the 1st epoch, and E22 from epochs 13 and
%               28.
% badsegs     - Number of max bad channels per epoch. If an epoch has
%               more than this number of bad channels, the epoch is
%               removed.
% badchans    - Proportion (e.g., 0.3) of max bad epochs per channel. If
%               a channel was found to be bad on more than this percent
%               of trials, it is removed.
% plot_bads   - [0|1] plot before executing. When plotting, will also ask
%               to confirm. If no plotting, will execute immediately.

```
## Using `pop_eegmaxmin`

### List of included functions

- `eegmaxmin` - new rejection method, based on max-min amplitude differences (available only for channel data, not IC activation).
- `pop_eegmaxmin` - call from EEGLAB menu of `eegmaxmin`. If no parameters are specified, pops a GUI window:

### Max-Min Threshold GUI

![pop_eegmaxmin](doc/maxmin_eg.png)

### Scripting
```matlab
[EEG, com] = pop_eegmaxmin(EEG); % pop-up interactive window mode

EEG        = pop_eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize);
% EEG         - input dataset.
% chanRange   - [1:EEG.nbchan] indecies for channels.
% timeRange   - [1:EEG.xmax*1000] range for inspection in ms.
% minmaxThresh- Threshold for the difference between max and min.
% winSize     - size of moving window (in ms).
% stepSize    - step size for moving window (in ms).
% maW         - moving average window size [default 0].
```
