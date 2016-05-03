function tom_lfpAnalysis(dataLFP)
par.nfft        = 2^9;
par.win         = 250;
par.noverlap    = 200;

params.tapers = [5 9]; %[5 9]
params.Fs = dataLFP.HEADER.fs_lfp;
params.fpass = [0 150];
movingwin = [0.2 0.01];

imin_freq = .1; 
imax_freq = 200;
qa_count = 0;

for ch = 1:5,
    Psd_Q = []; Psd_A=[];
    lfpQ = []; lfpA = [];

    for t = 1:dataLFP.HEADER.trialNo
        for qa = 1:2,
            qa_count = qa_count+1;
            % Estimate all PSD for Questions or Answers, can be parsed out aftewards
%             lfpQ = [lfpQ; dataLFP.TRIAL(t).lfp_QA(qa).Q(ch,:)];
% %             [specq, freqq, timeq, Psd_Q(:,:,qa_count)] = spectrogram(lfpQ, par.win, ...
% %                 par.noverlap, par.nfft, dataLFP.HEADER.fs_lfp);
%             Psd_Q(:,:,qa_count) =mtspecgramc( lfpQ, movingwin, params);

            lfpA= [lfpA; dataLFP.TRIAL(t).lfp_QA(qa).A(ch,:)];
%             [spec, freq, time, Psd_A(:,:,qa_count)] = spectrogram(lfpA, par.win, ...
%                 par.noverlap, par.nfft, dataLFP.HEADER.fs_lfp);
%             [Psd_A(:,:,qa_count), time, freq] =mtspecgramc( lfpA, movingwin, params);            
            % normalize to something, where's baseline?
            
        end % for question        
    end % for trial
    % 
%     Psd_Q = mtspecgramc( lfpQ', movingwin, params);
    [Psd_A, time, freq] = mtspecgramc( lfpA', movingwin, params);
    
    % Normalization
    blTime = time<0.5;
    % Baseline subtraction
    blSpecMean = mean(mean(Psd_A(blTime,:,:),3));
    bl_mean = repmat(blSpecMean,numel(time),1,100);
%     Psd_A = Psd_A - bl_mean;
    blSpecStd = std(mean(Psd_A(blTime,:,:),3));
    bl_std = repmat(blSpecStd,numel(time),1,100);
  Psd_A = (Psd_A - bl_mean)./bl_std;
    
    %% Q cats (belief/falsehood) 
    fig = figure;
    set(fig,'Position',[1 1 800 600])
    mean_psd_a = mean(Psd_A(:,:,dataLFP.HEADER.qCatVec==5),3);
    subplot(2,2,1)
    displaySpec(time, freq, mean_psd_a)
    name = sprintf('Case 1 Ch %d mean sub trialwise',ch);
    annotatePlot(name);
%     set(gcf,'name',name)
%     title(name)
    title('True Object')
    xlabel('Time around answer start (s)')
    
    mean_psd_a = mean(Psd_A(:,:,dataLFP.HEADER.qCatVec==4),3);
    subplot(2,2,2)
    displaySpec(time, freq, mean_psd_a)    
    title('False Object')
    xlabel('Time around answer start (s)')
    
    mean_psd_a = mean(Psd_A(:,:,dataLFP.HEADER.qCatVec==2),3);
    subplot(2,2,3)
    displaySpec(time, freq, mean_psd_a)    
    title('True Belief')
    xlabel('Time around answer start (s)')
    
    mean_psd_a = mean(Psd_A(:,:,dataLFP.HEADER.qCatVec==1),3);
    subplot(2,2,4)
    displaySpec(time, freq, mean_psd_a)    
    title('False Belief')
    xlabel('Time around answer start (s)')
    
    %% Q & A 
%     fig = figure;
%     set(fig,'Position',[1 1 800 600])
%     mean_psd_q = mean(Psd_Q,3);
%     subplot(1,2,1)
%     displaySpec(time, freq, mean_psd_q)
%     name = sprintf('Case 1 Ch %d',ch);
%     set(gcf,'name',name)
%     title(name)
%     xlabel('Time around question end (s)')
%     
%     mean_psd_a = mean(Psd_A,3);
%     subplot(1,2,2)
%     displaySpec(time, freq, mean_psd_a)
%     name = sprintf('Case 1 sess 1 Ch %d prob',ch);
%     set(gcf,'name',name)
%     title(name)
%     xlabel('Time around answer start (s)')
%     
     export_fig('ToM Case 1 Sess 1 LFP spect mean-norm.pdf', '-append'),
end % for channel
% 

min_freq = 1 + round(imin_freq/(freq(2)-freq(1)));
max_freq = 1 + round(imax_freq/(freq(2)-freq(1)));

%%
function displaySpec(time, freq, psd)
% surf(time, freq, 10*log10(abs(psd)+eps),'EdgeColor','none');
% surf(time(:), freq(:), 10*log10(abs(psd')+eps),'EdgeColor','none');
surf(time(:), freq(:), psd','EdgeColor','none');

set(gca,'xtick',0:1:6,'xticklabel',-3:1:3)

view(0,90);
% ylim([0 150])
ylim([0 max(freq)])

axis xy; axis tight;
colormap('default')
h = colorbar;
% h.Label.String = 'Power/Frequency (dB/Hz)';
h.Label.String = 'Normalized power (Z-score)';
xlabel('Time (s)')
ylabel('Frequency (Hz)')
hold on

theMax = max(max(10*log10(abs(psd)+eps)));
% plot3([3 3], [0 150], [theMax, theMax], 'k','linewidth',2)
plot3([3 3], [0 max(freq)], [theMax, theMax], 'k','linewidth',2)