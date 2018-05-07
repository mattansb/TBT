function tbt = tbt_bool2cell(bads,EEG)

tbt	= {[],{}};      % make empty list
for tr = 1:size(bads,2) % each trial
    if any(bads(:,tr)) % if has any bad channels
        tbt{end+1,1}    = tr;                                   % list trial number
        tbt{end,2}      = {EEG.chanlocs(bads(:,tr)==1).labels}; % list bad channels in current trial
    end
end
tbt = tbt(2:end,:); % remove first empty row

end