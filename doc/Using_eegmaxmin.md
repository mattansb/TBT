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

EEG        = pop_eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize,maW);
% to get more info, type 'help pop_eegmaxmin' in the command line.
```
