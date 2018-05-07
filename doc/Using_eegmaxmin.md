
<!-- README.md is generated from README.Rmd. Please edit that file -->
eegmaxmin
=========

Using `pop_eegmaxmin`
---------------------

### List of included functions

-   `eegmaxmin` - new rejection method, based on max-min amplitude differences (available only for channel data, not IC activation).
-   `pop_eegmaxmin` - call from EEGLAB menu of `eegmaxmin`. If no parameters are specified, pops a GUI window:

### Max-Min Threshold GUI

![pop\_eegmaxmin](maxmin_eg.png)

### Scripting

``` matlab
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
