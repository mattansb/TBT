# TBT
This EEGLAB plugin allows for the automatic rejection and iterpolation of channels on an epoch-by-epoch basis.


## Using `pop_TBT`
![pop_TBT](https://github.com/mattansb/TBT/blob/master/TBT_eg.png)


## Using `pop_eegmaxmin`
![pop_TBT](https://github.com/mattansb/TBT/blob/master/maxmin_eg.png)


## List of included functions:  
- `eegplugin_TBT` - EEGLAB plugin function.
- `pop_eegmaxmin` - call from EEGLAB menu of `eegmaxmin`.
- `eegmaxmin` - new rejection method, based on max-min amplitude differences (available only for channel data, not IC activation).
- `pop_TBT` - call from EEGLAB menu of `tbt_bcr`.
- `tbt_bcr` - epoch-by-epoch channel iterpolation, based on any rejection method used by EEGLAB, or a manual cell-array listing which channels to iterpolate in which epochs.
