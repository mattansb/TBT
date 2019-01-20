% clean_channels_rej() - Run clean_channels on a trial-by-trial basis.
%
% Usage:
%   EEG = clean_channels_rej(EEG,chanRange,corr_threshold,noise_threshold,window_len,max_broken_time,num_samples,subset_size);
%
% Inputs:
%   EEG         - input dataset.
%   chanRange   - [1:EEG.nbchan] indecies for channels.
%   
%   For other input arguments, see clean_channels
%    
% Outputs:
%   EEG     - output dataset with EEG.reject.rejcleanchanE and
%             EEG.reject.rejcleanchan.
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
%{
need to add this method to pop_TBT
%}
function EEG = clean_channels_rej(EEG,chanRange,corr_threshold,noise_threshold,window_len,max_broken_time,num_samples,subset_size)

clean_channels_args = {chanRange,corr_threshold,noise_threshold,...
    window_len,max_broken_time,num_samples,subset_size};

%% Run
bads = false(EEG.nbchan, EEG.trials);
for tt = 1:size(EEG.data,3)
    evalc('tempEEG = pop_select(EEG,''trial'',tt);');
    evalc('tempEEG = clean_channels(tempEEG,clean_channels_args{:});');
    try
        bads(chanRange,tt) = ~tempEEG.etc.clean_channel_mask(chanRange);
    end
end

%% Save
EEG.reject.rejcleanchanE    = double(bads);
EEG.reject.rejcleanchan     = double(any(bads,1));

fprintf('%d channel selected\n', length(chanRange));
fprintf('%d/%d trials contain channels marked as bad by clean_channels\n', sum(EEG.reject.rejcleanchan), EEG.trials);
end