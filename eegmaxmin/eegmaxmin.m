function EEG = eegmaxmin(EEG,chanRange,timeRange,minmaxThresh,winSize,stepSize,maW)

if isempty(chanRange),  chanRange   = 1:EEG.nbchan;                     end
if isempty(timeRange),  timeRange   = [EEG.xmin EEG.xmax]*1000;         end % in ms
if isempty(winSize),    winSize     = diff(timeRange);                  end % in ms
if isempty(stepSize),   stepSize    = ceil(winSize/10);                 end % in ms
if isempty(maW),        maW         = 0;                                end % in ms

% Prep data
t_ind       = EEG.times >= timeRange(1) & EEG.times <= timeRange(2);
c_ind       = chanRange;
cut_data    = EEG.data(c_ind,t_ind,:);

maW = round(maW/(1000/EEG.srate));
if maW > 0
    try
        cut_data    = movmean(cut_data,maW,2);
    catch
        warning('moving average supported only on Matlab 2016b+\nWill not compute moving average')
    end
end

winSize     = round(winSize/(1000/EEG.srate));
stepSize    = round(stepSize/(1000/EEG.srate));
w1          = [1:stepSize:(size(cut_data,2)-winSize) (size(cut_data,2)-winSize+1)];
we          = w1+winSize-1;

rej = false(size(EEG.data));
rej = permute(rej,[1,3,2]);
rej = rej(:,:,1:length(w1));
for tw = 1:length(w1)
    temp_x          = cut_data(:,w1(tw):we(tw),:);
    xmax            = max(temp_x,[],2);
    xmin            = min(temp_x,[],2);
    xdiff           = xmax-xmin;
    rej(c_ind,:,tw) = squeeze(xdiff>minmaxThresh);
end
rej = permute(rej,[1,3,2]);
rej = squeeze(any(rej,2));

EEG.reject.rejmaxminE   = double(rej);
EEG.reject.rejmaxmin    = double(any(rej,1));


fprintf('%d channel selected\n', length(chanRange));
fprintf('%d/%d trials contain channels that exceed threshold\n', sum(EEG.reject.rejmaxmin), EEG.trials);

end