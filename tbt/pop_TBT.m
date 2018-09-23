% pop_TBT() - Rejects and iterpolates channels on a epoch by epoch basis.
%
% Usage:
%   >>  EEG = pop_TBT(EEG,bads,badsegs,badchans,plot_bads,chanlocs);
%
%   only interpolate channels according to `bads`:
%   >>  EEG = pop_TBT(EEG,bads,EEG.nbchan,1,plot_bads,chanlocs); 
%
%   pop-up interative window mode:
%   >> [EEG, com, badlist]   = pop_TBT(EEG);
%
%
% When called from the eeglab GUI, the pop-up window will require the
% following:
%   Rejection Methods:
%       Rejection Method    - select which of the 5 standard eeglab
%                             rejection method (+1) to use.
%       Method argument     - Arguments to me passed to the rejection
%                             method function (the text below specifiys
%                             what needs to be defined).
%   Rejection Criteria:
%       Max % bad epochs per channel    - see bellow.
%       Max N bad channel per epoch     - see bellow.
%       Plot before executing           - if checked, will plot before
%                                         executing. 
%
% Inputs:
%   EEG         - input dataset
%   bads        - a boolean 2-d matrix (channels * trials) specifying "bad
%                 channels" for each epoch. OR
%                 a x-by-2 cell list, with the first column specifying the
%                 epochs, and the second column specifying the bad channels
%                 in those epochs. e.g.: {1,{'E12','E45'};[13 28],{'E22'}}
%                 will remove E12 and E45 from the 1st epoch, and E22 from
%                 epochs 13 and 28.
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
%   EEG     - output dataset.
%   badlist - number of bad channel and epochs removed
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

function [EEG, com, badlist] = pop_TBT(EEG,bads,badsegs,badchans,plot_bads,chanlocs)

com = '';

if nargin < 1
   help pop_TBT;
   return;
elseif nargin < 4
    
    methods = ['Abnormal values|'...
        'Abnormal trends|'...
        'Improbable data|'...
        'Abnormal distributions|'...
        'Abnormal spectra|'...
        'Max-Min Threshold'];

    methods2 = {...
        ['-10 , 10 ,' num2str(EEG.xmin) ' , ' num2str(EEG.xmax)],...
        'lowthresh, upthresh, starttime, endtime',...
        'pop_eegthresh';...
        ...
        [num2str(EEG.pnts) ' , 0.5 , 0.3'],...
        'winsize, maxslope, minR',...
        'pop_rejtrend';...
        ...
        '3 , 3',...
        'locthresh, globthresh',...
        'pop_jointprob';...
        ...
        '3 , 3',...
        'locthresh, globthresh',...
        'pop_rejkurt';...
        ...
        ['''method'' , ''FFT'' , ''threshold'' , [-30 , 30] ,''freqlimits'' , [15 , 30]'],...
        ' ',...
        'pop_rejspec';...
        ...
        ['[1:' num2str(EEG.nbchan) '],[' num2str([EEG.xmin EEG.xmax]*1000) '],100,' num2str([EEG.xmax - EEG.xmin]*1000) ',1,0'],...
        'chanRange,timeRange,minmaxThresh,winSize,stepSize,maW',...
        'pop_eegmaxmin';...
        };

    badTrial = num2str(max(ceil((EEG.nbchan-64)/6.5),4));
    
    [~, ~, ~, res] = inputgui( 'geometry', {[2.5] [0.6 1.4 0.5] [0.6 1.9] [0.6 1.9] [2.5] [2.5] [1 0.3 1.2] [1 0.3 0.2 1]}, 'geomvert', [1 1 1 1 0.5 1 1 1],...
        'title', 'pop_TBT() - Epoch by Epoch Rejection / Interpolation',...
        'uilist', { ...
        {'Style', 'text', 'string', 'Rejection Methods', 'fontweight', 'bold'  }...
        {'Style', 'text', 'string', 'Rejection Method' }...
        {'Style', 'popupmenu', 'string', methods, 'callback' @set_method 'tag' 'method' } ...
        {'Style', 'pushbutton', 'string', 'help', 'callback', @get_help}...
        {'Style', 'text', 'string', 'Method argument' }...
        {'Style', 'edit', 'string', methods2{1,1} 'tag' 'options' } ...
        {}...
        {'Style', 'text', 'string', methods2{1,2} 'tag' 'hint' } ...
        {}...
        {'Style', 'text', 'string', 'Rejection Criteria', 'fontweight', 'bold'  }...
        {'Style', 'text', 'string', 'Max % bad epochs per channel' }...
        {'Style', 'edit', 'string', '0.3' 'tag' 'badChan' }...
        {}...
        {'Style', 'text', 'string', 'Max N bad channel per epoch' }...
        {'Style', 'edit', 'string', badTrial 'tag' 'badTrial' }...
        {}...
        {'Style', 'checkbox', 'string' 'Plot before executing' 'value' 1 'tag' 'plot' }...
        } );
    
    try
    switch res.method
        case 1
            comrej  = ['EEG = pop_eegthresh(EEG, 1, 1:EEG.nbchan,' res.options ', 1, 0);'];
            bads    = 'EEG.reject.rejthreshE';
        case 2
            comrej  = ['[EEG, comrej] = pop_rejtrend(EEG, 1, 1:EEG.nbchan,' res.options ', 1, 0,0);'];
            bads    = 'EEG.reject.rejconstE';
        case 3
            comrej  = ['[EEG, ~,~,~,comrej] = pop_jointprob(EEG, 1, 1:EEG.nbchan,' res.options ', 1, 0, 0);'];
            bads    = 'EEG.reject.rejjpE';
        case 4
            comrej  = ['[EEG, ~,~,~,comrej] = pop_rejkurt(EEG, 1, 1:EEG.nbchan,' res.options ', 1, 0, 0);'];
            bads    = 'EEG.reject.rejkurtE';
        case 5
            comrej  = ['[EEG, ~, comrej]    = pop_rejspec(EEG, 1,' res.options ');'];
            bads    = 'EEG.reject.rejfreqE';
        case 6
            comrej  = ['[EEG, comrej]    = pop_eegmaxmin(EEG,' res.options ');'];
            bads    = 'EEG.reject.rejmaxminE';
    end    
    
    comtbt = ['EEG = pop_TBT(EEG,' bads ',' res.badTrial ',' res.badChan ',' num2str(res.plot) ');'];
    com = [comrej comtbt];
    eval([comrej]);
    eval([comtbt]);
    end
else
    if ~exist('plot_bads','var'), plot_bads = 1; end
    if exist('chanlocs','var')
        [EEG, nbadchan, nbadtrial] = tbt_bcr2(EEG,bads,badsegs,badchans,plot_bads,chanlocs);
    else
        [EEG, nbadchan, nbadtrial] = tbt_bcr2(EEG,bads,badsegs,badchans,plot_bads);
    end
    
    badlist.nbadchan  = nbadchan;
    badlist.nbadtrial = nbadtrial;
end
    
    % Set default method's text options and hint
    % ------------------------------------------
    function set_method(x,y)
        M_ind = get(gcbo, 'value');
        set(findobj(gcbf, 'tag', 'options'), 'string',methods2{M_ind,1});
        set(findobj(gcbf, 'tag', 'hint'), 'string',methods2{M_ind,2});
    end

    % Pop method's help
    % -----------------
    function get_help(x,y)
        M_ind = get(findobj(gcbf, 'tag', 'method'), 'value');
        eval(['pophelp(methods2{M_ind,3})'])
    end

end

