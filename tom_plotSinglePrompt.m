% plot a single prompt

% promptNo = 20;
ch = 1;
unit = 2;
binSize = 50;

promptTime(1) = min(data.transcription.Start(data.transcription.Prompt==promptNo));
promptTime(2) = max(data.transcription.End(data.transcription.Prompt==promptNo));
pt_s = round(promptTime*data.fs_audio);
prompt_sound = data.audio(pt_s(1):pt_s(2));

prompt_text = data.transcription.Words(data.transcription.Prompt==promptNo);
prompt_text_time = data.transcription.Start(data.transcription.Prompt==promptNo);
prompt_text_time = prompt_text_time-prompt_text_time(1);

% single unit
spikeTS = round(data.channel(ch).unit(:,unit).ts*1000);
bc = alignSpikesToEvent_2(spikeTS, promptTime(1)*1000, binSize);

% multiple units
bc = [];
for ch = 1:5,
    units = size(data.channel(ch).unit,2);    
    if ~isempty(units),
        for unit = 1:units
            spikeTS = round(data.channel(ch).unit(:,unit).ts*1000);
            bc = [bc, alignSpikesToEvent_2(spikeTS, promptTime(1)*1000, binSize)];
        end
    end
end

fr  = spikeDensity(bc, binSize);
smo = smoothSpikes(fr, 5, 'gauss')';
%% 
figure
subplot(2,1,1)
promptDur = promptTime(2)-promptTime(1);
plot(linspace(0, promptDur,length(prompt_sound)), prompt_sound)
hold on
text(prompt_text_time, ones(length(prompt_text),1), prompt_text)
plot([prompt_text_time(:), prompt_text_time(:), NaN(length(prompt_text),1)]', ...
    repmat([-1 1 NaN], length(prompt_text),1)','r')
xlim([0 promptDur])
hold off
% name = sprintf('Case %s Session %d prompt %d Channel %d Unit %d', data.case, ...
%     data.session, promptNo, ch, unit);
name = sprintf('Case %d Session %d prompt %d all', data.case, data.session, promptNo);

set(gcf,'name',['tom audio and unit ', name])
title(name)

subplot(2,1,2)
% fr_plot = smo((length(smo)/2):end);
toi = round((length(smo)/2)+1:((length(smo)/2)+1+(promptDur*1000)/binSize));
Y = bc(toi,:)'>0;
totalUnits = size(bc,2);
X = linspace(0,promptDur,size(Y,2));
imagesc(Y, 'XData', X, 'YData', 1:totalUnits)
hold on

fr_plot_norm =  normaliseMinMax(smo(toi))*totalUnits;
plot(X,fr_plot_norm,'r','linewidth',2)
set(gca,'ydir','normal')
hold off
