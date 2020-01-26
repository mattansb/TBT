# TBT 2.6.x

- `tbt_bool2cell` can now return a concise list, making the TBT process faster.

# TBT 2.6.0

- Works better with the new `eeglab2019`.
- Improved plotting menu.


# TBT 2.5.0

- `pop_TBT` now returns the epochs in the correct order (and also runs a lot faster) (previously, due to the function of `pop_mergeset`, the output EEG's trials were not necessarily in the same order as the input EEG - but the `urevents` could have been used as usual).
- When plotting in `pop_TBT`, a second array-plot is returned, allowing for a 'glance' at the rejected trials / channels.
- Fixed bug in `pop_eegmaxmin` where default value for `winSize` did not make sense.
- Fixed bug in `pop_TBT` where the returned `EEG` dataset would sometimes consist of a single concatenated trial, and not epoched data (caused by `eeglab`'s `pop_mergeset`).
