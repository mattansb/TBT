
# TBT


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241518.svg)](https://doi.org/10.5281/zenodo.1241518)

This EEGLAB plugin allows for the automatic rejection and interpolation of channels on an epoch-by-epoch basis.

It also comes with an additional method for rejecting epochs - max-minus-min threshold [(see here for more info)](./doc/Using_eegmaxmin.md).

## Downloading

-   You can download TBT through EEGLAB's data-processing extension GUI (*File &gt; Manage EEGLAB Extensions &gt; Data-Processing Extensions*).
-   Or as a `.zip` file from EEGLABS's servers [(TBT v2.0)](http://sccn.ucsd.edu/eeglab/plugins/TBT2.0.zip).
-   Or as a `.zip` file from the GitHub page [(TBT)](https://github.com/mattansb/TBT/releases).

## List of included functions

-   `eegplugin_TBT` - EEGLAB plugin function.
-   `tbt_bcr2` - epoch-by-epoch channel interpolation, based on any rejection method used by EEGLAB, or a manual cell-array listing which channels to interpolate in which epochs.
-   `tbt_bool2cell` - converts a boolean channel-by-trial matrix to a tbt ready cell-list (see bellow).
-   `tbt_cell2bool` - converts a tbt ready cell-list a boolean channel-by-trial matrix (see bellow).
-   `pop_TBT` - call from EEGLAB menu of `tbt_bcr`. If no parameters are specified, pops a GUI window.

## TBT GUI

Use the menu *Tools &gt; Epoch by Epoch Rejection/Interpolation*, or type into the command line:

``` matlab
[EEG, com, badlist] = pop_TBT(EEG); % pop-up interactive window mode
```

![](doc/TBT_eg.png)

You will be asked to select a rejection method, and set its parameters, and also to set the following:
1. **The maximum percent of bad trials per channel.** If a channel is bad on more then this percent of the trials, the channel will be removed across the whole data-set.
2. **The maximum number of bad channels per trial.** If a trial has more than this number of bad channels, the trial will be removed.
3. Whether to plot the marked channels and trials before rejecting and interpolating the marked channels.

![](doc/tbt_plot_eeg.png)
![](doc/tbt_plot_matrix.png)


## Scripting

Scripting takes to general following form:

``` matlab
% Use some rejection method:
EEG = pop_eegmaxmin(EEG);

% Send the 'rejE' matrix to pop_TBT:
my_bads = EEG.reject.rejmaxminE;
EEG = pop_TBT(EEG,my_bads,0.3,10);

% to get more info, type 'help pop_TBT' in the command line.
```

Scripting gives two major additional not available in the gui:

1.  Supplying a cell-list for rejection
2.  interpolating additional missing channels (thus making TBT an optional last step in pre-processing)

### Supplying a cell-list

A cell list can be manually created to mark bad channels in specific trials. For example, if we wish to remove E12 and E45 from the 1st epoch, and E22 from epochs 13 and 28, we would create a cell list to be used this list as input for `pop_TBT`:

``` matlab
my_bads = {...
  1,{'E12','E45'};...
  [13 28],{'E22'};...
  }
  
EEG = pop_TBT(EEG,my_bads,0.3,10);
                  
```

This method can also be combined with other `rejE` methods using the `tbt_cell2bool` function:

``` matlab
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
EEG = pop_TBT(EEG,my_bads,0.3,10);
                  
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

By default, trial-by-trial interpolation interpolates *only* the channels that are marked on a single-trial basis. i.e., channels marked as bad across the whole data-set will not be re-added by interpolation. If you wish to add them back (or any other channel that may have been removed in any previous processing step), channel locations can be added to `pop_tbt`:

``` matlab
% To add back all channels from the input EEG data-set:
EEG = pop_eegmaxmin(EEG);

my_bads = EEG.reject.rejmaxminE;

EEG = pop_TBT(EEG,my_bads,0.3,10,[],EEG.chanlocs); % or any other chanloc struct
                  
```

This makes TBT an ideal 'last step' in preprocessing - providing a clean data-set with all missing channels interpolated.

Author
------

-   **Mattan S. Ben-Shachar** \[aut, cre\] \<mattanshm at post.bgu.ac.il\>
