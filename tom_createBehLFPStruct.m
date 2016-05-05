function data = tom_createBehLFPStruct(lfp, preHeader)
% Generates structure 'data' which contains the LFP of each channel.
% 
% Example call: data = bias_createBehNeuronStruct(lfp, preHeader) 
%
% IN:
%     lfp, channel X samples
%     preHeader, structure w/ behavioural details. Must include field
%       'trialTimes_Sec' that is trials X 2 matrix w/ time stamps when a trial 
%       started and ended
% 
% OUT:
%     data, structure w/ LFP for each channel parsed by trial
%     
% See also bias_createBehNeuronStruct, tom_createBehLFPStruct, tom_master
% 
% RBM 12.15

nTrials     = preHeader.trialNo;

data = [];
data.HEADER = preHeader;

% Fancy notch filter at 60Hz and harmonics with band pass filter
% params.Fs     = preHeader.fs_lfp;
% params.tapers = [3 5];
% params.f0     = [60 180 300 420];
% [ch,sm] = size(lfp);
% filtLFP = zeros(ch, sm);
% for i = 1:ch,
%     filtLFP(i,:) = rmlinesc(single(lfp(i,:)), params);
% %     filtLFP(i,:) = CSCfilt(filtLFP(i,:), 0.01, preHeader.fs_lfp/2);
% end
% lfp = filtLFP;

preHeader.qTime_off = reshape(preHeader.qTime_off,nTrials,2);
preHeader.ansTime_on = reshape(preHeader.ansTime_on,nTrials,2);

% Chop LFP into trials, keep different channels in a matrix structure....
for t = 1:nTrials,       
    % extract LFP samples that correspond to the trial
    lr_s = round(preHeader.trialTimes_Sec(t,:)*preHeader.fs_lfp);
    data.TRIAL(t).lfp = single(lfp(:, lr_s(1):lr_s(2))); % change to float
    
    for qa = 1:2,
        % extract LFP samples that correspond to every Question
        lr_q = (preHeader.qTime_off(t,qa)-3000)/1000;% in S
        lr_q = floor([lr_q lr_q+6].*preHeader.fs_lfp);% in samples
        data.TRIAL(t).lfp_QA(qa).Q = single(lfp(:, lr_q(1):lr_q(2))); % change to float

        % extract LFP samples that correspond toevery answer (twice per trial)
%         lr_a = (preHeader.ansTime_on(t,qa)-3000)/1000;
%         lr_a = floor([lr_a lr_a+6]*preHeader.fs_lfp);
        lr_a = round(((preHeader.ansTime_on(t,qa)-3000)/1000)*preHeader.fs_lfp);
        lr_a(2) = lr_a(1) + 6*preHeader.fs_lfp;
        data.TRIAL(t).lfp_QA(qa).A = single(lfp(:, lr_a(1):lr_a(2))); % change to float
    end
    
    % Now append trial specifics      
    % Splice audio
    rge = preHeader.trialTimes_Spl(t,:);
    data.TRIAL(t).audio = preHeader.audio(rge(1):(rge(2)+22000));

    % Audio events
    data.TRIAL(t).audEv_Spl = preHeader.BHV(t);
    fld = fields(preHeader.BHV(t));
    for f = 1:length(fld)
        data.TRIAL(t).audEv_s.(fld{f}) = (preHeader.BHV(t).(fld{f})-rge(1))/11000;
    end
end % for trials



% Remove audio field to reduce memory laod
data.HEADER = rmfield(data.HEADER,'audio');

