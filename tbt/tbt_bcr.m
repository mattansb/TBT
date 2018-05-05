% tbt_bcr() - Rejects and iterpolates channels on a epoch by epoch basis.
%
% Usage:
%   >>  [EEG, nbadchan, nbadtrial] = tbt_bcr(EEG,bads,badsegs,badchans,plot_bads);
%
% Inputs:
%   EEG         - input dataset
%   bads        - a boolean 2-d matrix (channels * trials) specifying "bad
%                 channels" for each epoch. OR a cell array (see pop_TBT
%                 for specs).
%   badsegs     - Number of max bad channels per epoch. If an epoch has
%                 more than this number of bad channels, the epoch is
%                 removed.
%   badchans    - Proportion (e.g., 0.3) of max bad epochs per channel. If
%                 a channel was found to be bad on more than this percent
%                 of trials, it is removed.
%   plot_bads   - [0|1] plot before executing. When plotting, will also ask
%                 to confirm. If no plotting, will execute immediately.
%    
% Outputs:
%   EEG         - output dataset
%   nbadchan    - number of channels rejected
%   nbadtrial   - number of epochs rejected
%

% Copyright (C) 2017  Mattan S. Ben-Shachar
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [EEG, nbadchan, nbadtrial] = tbt_bcr(EEG,bads,badsegs,badchans,plot_bads)

%% convert bads from cell to array
if iscell(bads)
    fprintf('pop_TBT(): Converting cell-array.')
    bads_array = zeros([size(EEG.data,1) size(EEG.data,3)]);
    for r = 1:size(bads,1)
        % identift channels
        chan_i  = cellfun(@(x) any(strcmpi(x,bads{r,2})),{EEG.chanlocs.labels});
        epoch_i = bads{r,1};
        bads_array(chan_i,epoch_i) = 1;
    end
    bads = bads_array;
    fprintf('.. done.\n')
end

%% Find bad trials and Channels

% Find trial with more than X bad channels:
trials_ind  = 1:EEG.trials;
bTrial_ind  = sum(bads,1)>=badsegs;     % boolean list
bTrial_num  = trials_ind(bTrial_ind);	% trial list
nbadtrial   = length(bTrial_num);       % count bad trials

% Find channels that have been marked as bad in more than X% of trials:
bChan_ind           = (sum(bads,2)/EEG.trials)>=badchans;   % boolean list
bChan_lab           = {EEG.chanlocs(bChan_ind).labels};     % Channel label list 
nbadchan            = length(bChan_lab);                    % count bad channels
bads(bChan_ind,:)   = 1;                                    % mark for plotting

%% Plot

if isempty(plot_bads)
    plot_bads=0;
elseif ~any(plot_bads==[-1 0 1])
    error('plot_bads can only be 0, 1 (or empty - defaults to 0).')
end

if plot_bads==1
    mark = bads';

    mark(:,6:end+5)         = mark;
    mark(:,1)               = 1:EEG.pnts:EEG.pnts*EEG.trials;   % start sample
    mark(:,2)               = mark(:,1)+EEG.pnts;               % end   sample
    mark(~bTrial_ind,3:5)   = 1;                                % color for good trials (white)
    mark(bTrial_ind,3)      = 1;                                % R for bad trials
    mark(bTrial_ind,4)      = 0.9;                              % G for bad trials
    mark(bTrial_ind,5)      = 0.7;                              % B for bad trials
    eegplot(EEG.data(:,:,:),'srate', EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000 ,...
        'events', EEG.event ,'winrej',mark);
    uiwait(gcf);
    
    choice = questdlg(sprintf('Proceed?'), ...
        'Confirm', ...
        'Yes','No (do nothing)','Yes');
    switch choice
        case 'Yes'
            plot_bads = 0;
    end
end



if plot_bads==0
%% Remove bad channels and trials
    % Remove bad channels
    fprintf('\n')
    if ~isempty(bChan_lab) % if any bad channels
        fprintf('pop_TBT(): Dropping %d channel(s).',length(bChan_lab))
        evalc('EEG     = pop_select(EEG,''nochannel'',bChan_lab);');
        % EEG     = pop_select(EEG,'nochannel',bChan_lab);    % remove from data
        bads	= bads(~bChan_ind,:);                       % update bads matrix
        fprintf('.. done.\n')
    end

    % Remove bad trials
    if ~isempty(bTrial_num) % if any bad trials
        fprintf('pop_TBT(): Removing %d epoch(s).',length(bTrial_num))
        evalc('EEG     = pop_rejepoch(EEG, bTrial_num ,0);');
        % EEG     = pop_rejepoch(EEG, bTrial_num ,0); % remove from data
        bads    = bads(:,~bTrial_ind);              % update bads matrix
        fprintf('.. done.\n')
    end

    %% Interpolate bad channels (trial by trial)
    EEG_old = EEG; % need the old channlocs an events for later
    
    tbt	= {[],{}};      % make empty list
    for tr = 1:size(bads,2) % each trial
        if any(bads(:,tr)) % if has any bad channels
            tbt{end+1,1}    = tr;                                   % list trial number
            tbt{end,2}      = {EEG.chanlocs(bads(:,tr)==1).labels}; % list bad channels in current trial
        end
    end
    tbt = tbt(2:end,:); % remove first empty row
    
    if size(tbt,1)~=0
        fprintf('pop_TBT(): Splitting data')
        for t = 1:size(tbt,1) % each trial with bad channels
            if ~mod(t,5), fprintf('.'); end
            
            % split into sub data sets
            evalc('NEWEEG(t)   = pop_selectevent(EEG, ''epoch'',tbt{t,1} ,''deleteevents'',''off'',''deleteepochs'',''on'',''invertepochs'',''off'');');
            % NEWEEG(t)   = pop_selectevent(EEG, 'epoch',tbt{t,1} ,'deleteevents','off','deleteepochs','on','invertepochs','off');

            % Remove electrodes from each data set
            evalc('NEWEEG(t)   = pop_select(NEWEEG(t),''nochannel'',tbt{t,2});');
            % NEWEEG(t)   = pop_select(NEWEEG(t),'nochannel',tbt{t,2});
        end

        % Split all trials that did NOT have channels interpolated
        no_trls         = setdiff([1:EEG.trials],cell2mat(tbt(:,1)));   % trial not selected to have electrodes removed
        evalc('NEWEEG(end+1)   = pop_selectevent( EEG, ''epoch'',no_trls ,''deleteevents'',''off'',''deleteepochs'',''on'',''invertepochs'',''off'');');
        % NEWEEG(end+1)   = pop_selectevent( EEG, 'epoch',no_trls ,'deleteevents','off','deleteepochs','on','invertepochs','off');
        fprintf('.. done.\n')
        
        fprintf('pop_TBT(): Interpolating epoch-by-epoch')
        for t = 1:length(NEWEEG)
            if ~mod(t,5), fprintf('.'); end
            % Interpolate:
            evalc('NEWEEG(t)   = pop_interp(NEWEEG(t), EEG_old.chanlocs, ''spherical'');');
            % NEWEEG(t)   = pop_interp(NEWEEG(t), EEG_old.chanlocs, 'spherical');
            
            clear missing
        end
        fprintf('.. done.\n')
        
        % Merge
        fprintf('pop_TBT(): Merging data (this might take a while)..')
        evalc('EEG = pop_mergeset(NEWEEG, [length(NEWEEG) 1:length(NEWEEG)-1], 0);');
        % EEG = pop_mergeset(NEWEEG, [length(NEWEEG) 1:length(NEWEEG)-1], 0);
        
        % remove extra trimmmmmmmm from urevent
        nbound = sum(strcmpi('boundary',{EEG.urevent(:).type}));
        ur_ind = repmat([EEG_old.urevent.init_index nan],[1 (nbound+1)]);
        ur_ind = num2cell(ur_ind(1:end-1));
        [EEG.urevent.init_index2] = ur_ind{:};
        for e = 1:length(EEG.event)
            EEG.event(e).urevent = EEG.urevent(EEG.event(e).urevent).init_index2;
        end
        EEG.urevent = EEG_old.urevent;
        
        fprintf([repmat('\b',[1 28]) '... done.\n'])
    end
    
    EEG = eeg_checkset(EEG);
end

end