% pop_TBT() - Rejects and iterpolates channels on a epoch by epoch basis.
%
% Usage:
%   >> [EEG, com]   = pop_eegmaxmin(EEG); % pop-up interactive window mode
%   >>  EEG         = pop_eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize,maW);
%
% Inputs:
%   EEG         - input dataset.
%   chanRange   - [1:EEG.nbchan] indecies for channels.
%   timeRange   - [[EEG.xmin, EEG.xmax]*1000] range for inspection in ms.
%   minmaxThresh- Threshold for the difference between max and min.
%   winSize     - size of moving winsow (in ms).
%   stepSize    - step size for moving window (in ms).
%   maW         - moving average window size [defult 0].
%    
% Outputs:
%   EEG     - output dataset
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

function [EEG, com] = pop_eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize,maW)

com = '';

if nargin < 1
   help pop_eegmaxmin;
   return;
elseif nargin < 6
    [~, ~, ~, res] = inputgui(...
        'geometry', {[1] [0.5 0.5] [0.5 0.5] [0.5 0.5] [0.5 0.5] [0.5 0.5] [0.5 0.5]},...
        'geomvert', [1 1 1 1 1 1 1],...
        'title', 'pop_eegmaxmin() - Rejection Max-Min Threshold',...
        'uilist', { ...
        {'Style', 'text', 'string', 'Rejection Max-Min Threshold', 'fontweight', 'bold'  }...
        {'Style', 'text', 'string', 'Threshold' }...
        {'Style', 'edit', 'string', '100' 'tag' 'thresh' } ...
        {'Style', 'text', 'string', 'Time Range (in ms)' }...
        {'Style', 'edit', 'string', num2str([EEG.xmin EEG.xmax]*1000) 'tag' 'times' } ...
        {'Style', 'text', 'string', 'Channels' }...
        {'Style', 'edit', 'string', ['1:' num2str(EEG.nbchan)] 'tag' 'chans' } ...
        {'Style', 'text', 'string', 'Window Size (in ms)' }...
        {'Style', 'edit', 'string', num2str(floor([EEG.xmax - EEG.xmin]/2*1000)) 'tag' 'win' } ...
        {'Style', 'text', 'string', 'Step Size (in ms)' }...
        {'Style', 'edit', 'string', '1' 'tag' 'step' } ...
        {'Style', 'text', 'string', 'compute moving average of (in ms):' }...
        {'Style', 'edit', 'string', '0' 'tag' 'maW' } ...
        } );
    
    com = ['EEG = pop_eegmaxmin(EEG,[' res.chans '],[' res. times '],[' res.thresh '],[' res.win '],[' res.step '],[' res.maW ']);']; 
    eval([com]);
else
    EEG = eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize,maW);
end

end