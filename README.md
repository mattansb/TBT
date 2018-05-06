
<!-- README.md is generated from README.Rmd. Please edit that file -->
TBT
===

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241518.svg)](https://doi.org/10.5281/zenodo.1241518)

This EEGLAB plugin allows for the automatic rejection and interpolation of channels on an epoch-by-epoch basis.

It also comes with an additional method for rejecting epochs - max-minus-min threshold.

Downloading
-----------

-   You can download TBT through EEGLAB's data-processing extension GUI (*File &gt; Manage EEGLAB Extensions &gt; Data-Processing Extensions*).
-   Or as a `.zip` file from EEGLABS's servers [(TBT v1.5)](http://sccn.ucsd.edu/eeglab/plugins/TBT1.5.zip).
-   Or as a `.zip` file from the GitHub page [(TBT)](https://github.com/mattansb/TBT/releases).

Using TBT
---------

### List of included functions

-   `eegplugin_TBT` - EEGLAB plugin function.
-   `tbt_bcr` - epoch-by-epoch channel interpolation, based on any rejection method used by EEGLAB, or a manual cell-array listing which channels to interpolate in which epochs.
-   `tbt_bool2cell` - converts a bollian channel-by-trial matrix to a tbt ready cell-list (see bellow).
-   `tbt_cell2bool` - converts a tbt ready cell-list a bollian channel-by-trial matrix (see bellow).
-   `pop_TBT` - call from EEGLAB menu of `tbt_bcr`. If no parameters are specified, pops a GUI window.

### TBT GUI

Use the menu.....

Or, by typing into the command line:

``` matlab
[EEG, com, badlist] = pop_TBT(EEG); % pop-up interactive window mode
```

![pop\_TBT](doc/TBT_eg.png)

### Scripting

``` matlab
EEG = pop_TBT(EEG,bads,badsegs,badchans,plot_bads,chanlocs);
% to get more info, type 'help pop_TBT' in the command line.
```
