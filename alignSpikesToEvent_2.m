function binCount = alignSpikesToEvent_2(spikeTS, events, binSize) 
%  binCount = alignSpikesToEvent_2(spikeTS, events, binSize)
% 
% In
%   timestamps, vector   
%   event, vector
%   binSize, integer
%
% Out
%   binCount --     spike count per bin. Bins X Trials
%
% see also sitParse, sitParse2, plotAllFixations, alignSpikesToEvent
% 
% RBM 5.16

smpl = [10000 10000]; 
binCount  = single(NaN(round(sum(smpl)/binSize),length(events))); 

% Loop every event and align all spikes occuring 10s before and 10s after
for i = 1:length(events),         
    binLimits = events(i)-smpl(1): binSize : events(i)+smpl(2)-binSize;        

    % bin spikes
    binCount(:,i) = histc(spikeTS, binLimits);    
end

