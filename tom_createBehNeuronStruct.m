function data = tom_createBehNeuronStruct(all_ts_no, preHeader)
% Generates structure 'data' which contains the time stamps of each unit.
% 
% Example call: data = bias_createBehNeuronStruct(Spikes, preHeader) 
%
% IN:
%     all_ts_no, spikes X 3 matrix output from offline sorter
%     preHeader, structure w/ behavioural details. Must include field
%       'trialTimes_Sec' that is trials X 2 matrix w/ time stamps when a trial 
%       started and ended
% 
% OUT:
%     data, structure w/ time stamps for each unit parsed by trial
%     
% See also bias_createBehNeuronStruct, tom_master
% 
% RBM 11.15

nTrials     = preHeader.trialNo;
[ch,~,chId] = unique(all_ts_no(:,1));
nChannels   = length(ch);

data = [];

% We work with every channel that contained units
for j = 1:nChannels,    
    data(j).HEADER = preHeader;
    unitsInCh = length(unique(all_ts_no(chId==j,2)));
    data(j).HEADER.units = unitsInCh;
    data(j).HEADER.channel = ch(j);
    
    % loop each unit
    for jj = 1:unitsInCh,  
        channel = chId==j;        
        unit    = all_ts_no(:,2)==jj;
        unitTS  = all_ts_no(channel & unit,3); % in seconds

        for t = 1:nTrials,
            % Reference to the start of a prompt, end of last answer + 3s               
            trialTS = unitTS(unitTS > preHeader.trialTimes_Sec(t,1) & ...
                             unitTS < preHeader.trialTimes_Sec(t,2));
            % Spike time stamps in ms referenced to trial start
            data(j).TRIAL(t).unit(jj).ts = ...
                round((trialTS - preHeader.trialTimes_Sec(t,1)).*1000);

            % Now append trial specifics (this is repeated on every
            % channel), it comes from preHeader
            if jj == 1,
                % Splice audio
                rge = preHeader.trialTimes_Spl(t,:);
                data(j).TRIAL(t).audio = preHeader.audio(rge(1):(rge(2)+22000));
                
                % Audio events
                data(j).TRIAL(t).audEv_Spl = preHeader.BHV(t);
                fld = fields(preHeader.BHV(t));
                for f = 1:length(fld)
                    data(j).TRIAL(t).audEv_s.(fld{f}) = (preHeader.BHV(t).(fld{f})-rge(1))/11000;
                end
            end
        end
       
    end
end

