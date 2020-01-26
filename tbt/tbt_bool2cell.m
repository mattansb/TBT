function bads_cellist = tbt_bool2cell(bads,EEG, concise)
if ~exist('concise','var'), concise = false; end

bads_cellist = cell(size(bads,2),2);
for tr = 1:size(bads,2) % each trial
    bads_cellist{tr,1} = tr;                                   % list trial number
    bads_cellist{tr,2} = {EEG.chanlocs(bads(:,tr)==1).labels}; % list bad channels in current trial
end

if concise
    for tr = 1:size(bads,2) % each trial
        if isempty(bads_cellist{tr,2})
            continue
        end
        
        i = cellfun(@(C) isequal(C, bads_cellist{tr,2}) ,{bads_cellist{:,2}});
        i = find(i);
        bads_cellist{tr,1} = i;
        
        i = setdiff(i,tr);
        [bads_cellist{i,2}] = deal({});
    end
end

bads_cellist = bads_cellist(~cellfun(@isempty,bads_cellist(:,2)),:);

end