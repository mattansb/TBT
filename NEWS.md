# TBT 2.5.0

- `pop_TBT` now returns the epochs in the correct order (and also runs a lot faster) (previously, due to the fucntion of `pop_mergeset`, the output EEG's trials were not necessarily in the same order as the input EEG - but the `urevents` could have been used as usual).
- When plotting in `pop_TBT`, a second array-plot is returned, allowing for a 'glance' at the rejected trials / channels.
- Fixed bug in `pop_eegmaxmin` where defult value for `winSize` did not make sense.
- Fixed bug in `pop_TBT` where the returned `EEG` dataset would sometimes consist of a single concatenated trial, and not epoced data (caused by `eeglab`'s `pop_mergeset`).
