function bads_cellist = tbt_bool2cell(bads,EEG)

bads_cellist	= {[],{}};      % make empty list
for tr = 1:size(bads,2) % each trial
    if any(bads(:,tr)) % if has any bad channels
        bads_cellist{end+1,1}    = tr;                                   % list trial number
        bads_cellist{end,2}      = {EEG.chanlocs(bads(:,tr)==1).labels}; % list bad channels in current trial
    end
end
bads_cellist = bads_cellist(2:end,:); % remove first empty row

end