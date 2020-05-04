
# TBT


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241518.svg)](https://doi.org/10.5281/zenodo.1241518)

This EEGLAB plugin allows for the automatic rejection and interpolation of channels on an epoch-by-epoch basis.

It also comes with an additional method for rejecting epochs - max-minus-min threshold [(see here for more info)](./doc/Using_eegmaxmin.md).

You can reference the plugin and its documentation as follows:

- Ben-Shachar, M. S. (2018). TBT: Reject and Interpolate channels on a trial-by-trial basis. Zenodo. [http://doi.org/10.5281/zenodo.3627791](http://doi.org/10.5281/zenodo.3627791)

See ***Scripting*** below for a citation example.

## Downloading

-   You can download TBT through EEGLAB's data-processing extension GUI (*File &gt; Manage EEGLAB Extensions &gt; Filter by artifact*).
-   Or as a `.zip` file from the GitHub page [(TBT)](https://github.com/mattansb/TBT/releases).

## List of included functions

-   `eegplugin_TBT` - EEGLAB plugin function.
-   `tbt_bcr2` - epoch-by-epoch channel interpolation, based on any rejection method used by EEGLAB, or a manual cell-array listing which channels to interpolate in which epochs.
-   `tbt_bool2cell` - converts a boolean channel-by-trial matrix to a tbt ready cell-list (see bellow).
-   `tbt_cell2bool` - converts a tbt ready cell-list a boolean channel-by-trial matrix (see bellow).
-   `pop_TBT` - call from EEGLAB menu of `tbt_bcr`. If no parameters are specified, pops a GUI window.

## TBT GUI

Use the menu *Tools &gt; Epoch by Epoch Rejection/Interpolation*, or type into the command line:

```Matlab
[EEG, com, badlist] = pop_TBT(EEG); % pop-up interactive window mode
```

![](doc/TBT_eg.png)

You will be asked to select a rejection method, and set its parameters, and also to set the following:
1. **The maximum percent of bad trials per channel.** If a channel is bad on more then this percent of the trials, the channel will be removed across the whole data-set.
2. **The maximum number of bad channels per trial.** If a trial has more than this number of bad channels, the trial will be removed.
3. Whether to plot the marked channels and trials before rejecting and interpolating the marked channels.

If you select `Plot before executing`, a pop-up window will appear, allowing for two kinds of plots:

- ***A scrolling EEG plot***, with bad channels marked in red, and bad trials marked in yellow:  

![](doc/tbt_plot_eeg.png)

- ***A matrix plot***:
  - Red horizontal bars mark channels that will be completely removed,  
  - Red vertical bars mark trials that will be completely removed,  
  - Colored dots mark which channels that will be removed and interpolated on a trial-by-trial basis.  

![](doc/tbt_plot_matrix.png)


## Scripting

Scripting takes to general following form:

```Matlab
% Use some rejection method:
EEG = pop_eegmaxmin(EEG);

% Send the 'rejE' matrix to pop_TBT:
my_bads = EEG.reject.rejmaxminE;
EEG = pop_TBT(EEG,my_bads,10,0.3);

% to get more info, type 'help pop_TBT' in the command line.
```

Scripting gives two major additional not available in the gui:

1.  Supplying a cell-list for rejection
2.  interpolating additional missing channels (thus making TBT an optional last step in pre-processing)

### Supplying a cell-list

A cell list can be manually created to mark bad channels in specific trials. For example, if we wish to remove E12 and E45 from the 1st epoch, and E22 from epochs 13 and 28, we would create a cell list to be used this list as input for `pop_TBT`:

```Matlab
my_bads = {...
  1,{'E12','E45'};...
  [13 28],{'E22'};...
  }
  
EEG = pop_TBT(EEG,my_bads,10,0.3);
                  
```

This method can also be combined with other `rejE` methods using the `tbt_cell2bool` function:

```Matlab
% Specify cell-list
my_bads = {...
  1,{'E12','E45'};...
  [13 28],{'E22'};...
  }

% transforms the cell-list into a 'rejE'-like matrix.
my_bads = tbt_cell2bool(my_bads,EEG);

% combine with automatic method:
EEG = pop_eegmaxmin(EEG);


my_bads = my_bads | EEG.reject.rejmaxminE;
EEG = pop_TBT(EEG,my_bads,10,0.3);
                  
```
The `tbt_bool2cell` function is the reverse of `tbt_cell2bool`, converting a boolean `rejE` matrix to a tbt-ready cell-list. For example:

```Matlab

EEG = pop_eegmaxmin(EEG);

tbt_bool2cell(EEG.reject.rejmaxminE, EEG)

>> ans =
>> 
>>   70ª2 cell array
>> 
>>     [ 2]    {'E64'	'E90'}
>>     [ 3]    {'E63'	'E64'	'E68'	'E90'	'E99'}
>>     [ 5]    {'E68'	'E73'}
>>      ...

```

### Interpolating all missing channels

By default, trial-by-trial interpolation interpolates *only* the channels that are marked on a single-trial basis. i.e., channels marked as bad across the whole data-set will not be re-added by interpolation. If you wish to add them back (or any other channel that may have been removed in any previous processing step), channel locations can be added to `pop_TBT`:

```Matlab
% To add back all channels from the input EEG data-set:
EEG = pop_eegmaxmin(EEG);

my_bads = EEG.reject.rejmaxminE;

EEG = pop_TBT(EEG,my_bads,10,0.3,[],EEG.chanlocs); % or any other chanloc struct
                  
```

This makes TBT an ideal 'last step' in preprocessing - providing a clean data-set with all missing channels interpolated.

### Citation Example

This is a citation example for the following code:

```Matlab
EEG = pop_eegmaxmin(EEG, [],[], 75, [], 1, 0);

EEG = pop_TBT(EEG, EEG.reject.rejmaxminE , 10, 0.15, 1);
```

of the max-min method + TBT:

> Epoched data were subjected to an automated bad-channel and artifact detection using EEGPLAB's *TBT* plugin (Ben-Shachar, 2020): within each epoch, channels that exceeded a differential average amplitude of 75μV were marked for rejection. Channels that were marked as bad on more then 15/% of all epochs were excluded. Epochs having more than 10 bad channels were excluded. Epochs with less than 10 bad channels were included, while replacing the bad-channel data with spherical interpolation of the neighboring channel values.

Author
------

-   **Mattan S. Ben-Shachar** \[aut, cre\] \<mattanshm at post.bgu.ac.il\>
