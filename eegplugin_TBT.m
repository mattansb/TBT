% TBT - Reject and iterpolate channels on a epoch by epoch basis.
%
% The main functions are:
%   >>  EEG = pop_TBT(EEG);
%   >>  EEG = pop_eegmaxmin(EEG);
%
% Copyright (C) 2019  Mattan S. Ben-Shachar
% 
% Read more at: https://github.com/mattansb/TBT
function eegplugin_TBT (fig, trystrs, catchstrs)

% Add sub-folders to path
path = strrep(which(mfilename),[mfilename '.m'],'');
addpath([path '/eegmaxmin'])
addpath([path '/tbt'])

% main TBT function
dothething1 = [  trystrs.no_check,...
                '[EEG, LASTCOM] = pop_TBT(EEG);'...
                '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);',...
                catchstrs.store_and_hist];
toolsmenu = findobj(fig, 'tag', 'tools');
uimenu(toolsmenu, 'label', 'Epoch by Epoch Rejection / Interpolation', ...
    'callback', dothething1,...
    'userdata', 'continuous:off');

% add max-min to 'Reject data epochs'

try
    dothething2 = [  trystrs.no_check,...
        '[EEG, LASTCOM] = pop_eegmaxmin(EEG);'...
        '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);',...
        catchstrs.store_and_hist];
rejsmenu = findobj(toolsmenu,'Label', 'Reject data epochs');
uimenu(rejsmenu, 'label', 'Reject by Max-Min Threshold', ...
    'callback', dothething2,...
    'userdata', 'continuous:off',...
    'position', 8 );
catch
    fprintf('\tTBT: Cannot add Max-min to ''Reject data epochs''; try enabling the old menu style.\n');
end


end