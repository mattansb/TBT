% tbt_bcr2() - Rejects and iterpolates channels on a epoch by epoch basis.
%
% Usage:
%   >>  [EEG, nbadchan, nbadtrial] = tbt_bcr2(EEG,bads,badsegs,badchans,plot_bads,chanlocs);
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
%   chanlocs    - [optional] a chanlocs struct (e.g., EEG.chanlocs). If
%                 provided, missing channels will be interpolated according
%                 to this struct, and not the input EEG. NOTE that if not
%                 provided, channel that have been rejected across the
%                 dataset (according to the badchans critirion) will not be
%                 interpolated back in.
%    
% Outputs:
%   EEG         - output dataset
%   nbadchan    - number of channels rejected
%   nbadtrial   - number of epochs rejected
%

% Copyright (C) 2018  Mattan S. Ben-Shachar
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


function [EEG, nbadchan, nbadtrial] = tbt_bcr2(EEG,bads,badsegs,badchans,plot_bads,chanlocs)

%% convert bads from cell to array



if iscell(bads)
    fprintf('pop_TBT(): Converting cell-array to logical array')
    bads = tbt_cell2bool(bads,EEG);
    fprintf('.. done.\n')
elseif ~islogical(bads)
    fprintf('pop_TBT(): Converting to logical array')
    bads = logical(bads);
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
    plot_bads = tbt_plot(EEG,bads,bTrial_ind,bChan_ind);
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
    if ~exist('chanlocs','var')
        interp_all = false;
        chanlocs = EEG.chanlocs;
    else
        interp_all = true;
    end
    
    % convert bool array to n-by-2 cell-list
    tbt = tbt_bool2cell(bads,EEG);
    
    if size(tbt,1)~=0
        fprintf('pop_TBT(): %d channel(s) are bad on at least 1 trial.\n',sum(any(bads,2)))
        fprintf('           %d trials(s) contain at least 1 bad channel.\n',sum(any(bads,1)))
        
        fprintf('pop_TBT(): Interpolating epoch-by-epoch..')
        for t = 1:size(tbt,1) % each trial with bad channels
            if ~mod(t,5), fprintf('.'); end
            
            % split
            evalc('tempeeg(t) = pop_selectevent(EEG, ''epoch'',tbt{t,1});');

            % remove bad channels
            evalc('tempeeg(t) = pop_select(tempeeg(t),''nochannel'',tbt{t,2});');

            % interp single trial
            evalc('tempeeg(t) = pop_interp(tempeeg(t), chanlocs, ''spherical'');');
        end
        
        evalc('EEG = pop_interp(EEG, chanlocs, ''spherical'');'); % to match all channels to the chanloc channel
        tempeeg = cat(3,tempeeg.data);              % gather all data
        EEG.data(:,:,cat(1,tbt{:,1})) = tempeeg;    % re-add to EEG.data

        fprintf('.. done.\n')
    elseif interp_all
        fprintf('pop_TBT(): Interpolating missing channels')
        evalc('EEG = pop_interp(EEG, chanlocs, ''spherical'');');
        fprintf('.. done.\n')
    end
    
    EEG = eeg_checkset(EEG);
end

end