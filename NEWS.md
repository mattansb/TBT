# TBT 2.0+

- When plotting in `pop_TBT`, a second array-plot is returned, allowing for a 'glance' at the rejected trials / channels.
- Fixed bug in `pop_eegmaxmin` where defult value for `winSize` did not make sense.
- Fixed bug in `pop_TBT` where the returned `EEG` dataset would sometimes consist of a single concatenated trial, and not epoced data (caused by `eeglab`'s `pop_mergeset`).
