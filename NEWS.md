# TBT 2.0+

- Fixed bug in `tbt_bcr` where the returned `EEG` dataset would sometimes consist of a single concatenated trial, and not epoced data (caused by `eeglab`'s `pop_mergeset`).

