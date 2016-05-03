% Neuronal raster with behavioural markers




%% Flexible plot of SDF
params.plotRange    = [3000 3000];
params.binSize      = 5;
params.smo          = 30;
plotTime = 'question';
plotCat = 'categ';

plotRange   = params.plotRange;
binSize     = params.binSize;
smo         = params.smo;

switch plotTime,
    case 'question'
        alignEvent = [repmat((1:nTrials)',2,1), qTime_off];
        xl = 'Time from end of question (s)';
    case 'answer'
        alignEvent = [repmat((1:nTrials)',2,1), ansTime_on];
        xl = 'Time from start of answer (s)';

end
bc = alignSpikesToEvent(data(ch), alignEvent, binSize, unit);
middle = size(bc,1)/2;
% variable 'bc' is: [t1q1;t1q2;t2q1;t2q2;... etc] re-arrange to have the
% same arrangement as all others...
arrange = [(1:2:(nTrials*2))'; (2:2:(nTrials*2))'];
bc = bc(:,arrange);

figure
hdl(1) = gca;
name = sprintf('SDF %s %s case %d sess %d ch %d unit %d', plotTime, plotCat, ...
            data(1).HEADER.case,...
            data(1).HEADER.session, ....
            data(ch).HEADER.channel, unit);
        
switch plotCat
    case 'correct'
        plotSDF(bc, correct, 1, binSize, smo, plotRange, 1, ...
            hdl(1), 'flexible', middle); 
        xlabel(xl)
        legend({'Incorr','Corr','Pass'})
    case 'categ'        
        plotSDF(bc, qCatVec, 1, binSize, smo, plotRange, 0, ...
            hdl(1), 'flexible', middle); 
        xlabel(xl)
        legend({'FB','TB','DTB','FO','TO'})
end
title(name)
set(gcf,'name',name)
figName = sprintf('ToM Case %d Sess %d %s %s SDF.pdf', ...
            data(1).HEADER.case, data(1).HEADER.session, plotTime, plotCat);
export_fig(figName, '-append'),

%%
% categories = qCatVec;
% spikes = bc;
% noCats = length(unique(categories));
% 
% figure,
% for i = 1:noCats,
%     subplot(1,noCats,i)
%     [spkPerS, stdFR, semFR] =  spikeDensity(spikes(:,categories==i), binSize);
%     bar(spkPerS), box off, 
%     set(gca,'tickdir','out')
%     xlim([middle-(plotRange(1)/binSize), middle+(plotRange(2)/binSize)])
% end
%% RASTER
% rstrRg = [4000, 2000];
% figure
% plotRaster(bc, qCatVec, 1, binSize, rstrRg, gca, 'raster', middle,...   
%     'colors',       'flexible',...
%     'rasterheigth',     1.75);
% name = sprintf('raster %s %s %s ch %d unit %d', plotTime, plotCat, ...
%             data(1).HEADER.session, ....
%             data(ch).HEADER.channel, unit);
% title(name)
% set(gcf,'name',name)  
% figName = sprintf('ToM Case %d Sess %d %s %s raster.pdf', ...
%             data(1).HEADER.case, data(1).HEADER.session, plotTime, plotCat);
% export_fig(figName, '-append'),


