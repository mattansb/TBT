function plot_bads = tbt_plot(EEG,bads,bTrial_ind,bChan_ind)

plot_bads = 1;

%% Plot Matrix at a glance

% Prep for plotting
forplot_bads = double(~bads);
forplot_bads(:,bTrial_ind) = EEG.trials + 1;
for tr = 1:EEG.trials
    forplot_bads(bads(:,tr),tr) = tr;
end
forplot_bads(bChan_ind,:) = EEG.trials + 1;

% Plot
figure; imagesc(forplot_bads);
colormap([1 1 1; rand([EEG.trials 3]); [1 .25 .25]])
title('Bad channels by trial')
xlabel('Trial'); ylabel('Channel');
yticks(1:EEG.nbchan); yticklabels({EEG.chanlocs.labels});
annotation('textbox', [0.1, 0.07, 0, 0],...
    'String', 'Each trial is marked by a color. Red lines indicate a channel or trial that will be completelty removed. ',...
    'FitBoxToText', 'on', 'LineStyle', 'none');

%% Plot EEG

% Prep for plotting
mark                    = ones([0,5] + size(bads'));
mark(:,6:end)           = double(bads');
mark(:,1)               = 1:EEG.pnts:EEG.pnts*EEG.trials;   % start sample
mark(:,2)               = mark(:,1)+EEG.pnts;               % end   sample
mark(bTrial_ind,3)      = 1;                                % R for bad trials
mark(bTrial_ind,4)      = 0.9;                              % G for bad trials
mark(bTrial_ind,5)      = 0.7;                              % B for bad trials

% Plot
eegplot(EEG.data(:,:,:), 'winrej',mark, 'events', EEG.event ,...
    'srate', EEG.srate, 'limits', [EEG.xmin EEG.xmax]*1000);

%% Wait for respons
uiwait(gcf);
dlgmsstxt = sprintf(...
    ['%d trial and %d channels will be completely removed. Additionally:\n'...
    '%d channel(s) are bad on at least 1 trial.\n'...
    '%d trial(s) contain at least 1 bad channel\n'...
    '\n',...
    'Proceed?'],...
    sum(bTrial_ind),...
    sum(bChan_ind),...
    sum(any(bads(~bChan_ind,~bTrial_ind),2)),...
    sum(any(bads(~bChan_ind,~bTrial_ind),1)));

choice = questdlg(...
    dlgmsstxt, ...
    'Confirm', ...
    'Yes','No (do nothing)','Yes');
switch choice
    case 'Yes'
        plot_bads = 0;
end
end