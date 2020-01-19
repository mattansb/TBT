function bads_array = tbt_cell2bool(bads,EEG)

% initiate empty array
bads_array = false([size(EEG.data,1) size(EEG.data,3)]);

% mark bad channel per trial
for r = 1:size(bads,1) % for each row
    % identify channels
    chan_i  = cellfun(@(x) any(strcmpi(x,bads{r,2})),{EEG.chanlocs.labels});
    % identify epochs
    epoch_i = bads{r,1};
    % mark as bad
    bads_array(chan_i,epoch_i) = true;
end

end