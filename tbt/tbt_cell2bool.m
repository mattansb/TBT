function bads_array = tbt_cell2bool(bads,EEG)

bads_array = false([size(EEG.data,1) size(EEG.data,3)]);

for r = 1:size(bads,1)
    % identift channels
    chan_i  = cellfun(@(x) any(strcmpi(x,bads{r,2})),{EEG.chanlocs.labels});
    epoch_i = bads{r,1};
    bads_array(chan_i,epoch_i) = true;
end

end