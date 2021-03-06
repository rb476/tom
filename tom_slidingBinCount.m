function [slidBC, slidCtr] = tom_slidingBinCount(spikeTS, events, time, inputsize, stepsize)
% slidBC = tom_slidingBinCount(data, unit, epochNo, time, inputsize, stepsize)
%
% Obtain impulse bin count for every sliding window in ToM project.
%
%   Input: 
%         spikeTS, vector with unit's spiking time stamps ( in ms)
%         events, vector used to align neuronal data (in ms)
%         time, start and end of task epoch of interest (both positive, in ms)
%         inputsize, window size (in ms)
%         stepsize, sliding window time step (in ms)
%
%   output:
%         slidBC, sliding window spike bin count
%         slidCtr, sliding window center
%
% rbm 5.16
%
% See also slidingBinCount

% Obtain # of slides for the requested parameters
theseSlides = (sum(time)-inputsize+stepsize)/stepsize;
if mod(theseSlides,round(theseSlides))~=0,
    error('Non-integer # of bins for bin size %d and step %d',inputsize,stepsize)
end

% Obtain impulse count and bin it depending on epoch
bc = alignSpikesToEvent_2(spikeTS, events, stepsize);
middle = floor(size(bc, 1)/2);

% Z-score to ca. 1s pre event
% toi = middle-ceil(1000/stepsize):middle-1;
% mbl = mean(bc(toi,:));
% sdl = std(bc(toi,:));
% for i = 1:size(bc,2),
%     bc_z(:,i) = (bc(:,i) - mbl(i))./ sdl(i);
% end

% Z-score to first 10 s of recording
% blSpikes = spikeTS<10000;
% if sum(blSpikes)>0,
%     bl_bc = histc(spikeTS(blSpikes),0:stepsize:10000);
% else
%     blSpikes = spikeTS<=spikeTS(1)+10000;    
%     bl_bc = histc(spikeTS(blSpikes), spikeTS(1):stepsize:(spikeTS(1)+10000));
% end
% mbl = mean(bl_bc);
% sbl = mean(bl_bc);
% bc_z = (bc-mbl)/sbl;
% 
% bc = bc_z;

% Obtain impulse bin count for every sliding window 
slidBC = zeros(theseSlides,size(bc,2));

for ii = 1:theseSlides,
    toi  = middle - time(1)/stepsize + ii : ...
           middle - time(1)/stepsize + ii + (inputsize/stepsize)-1;
    slidBC(ii,:) = sum(bc(toi,:), 1);
end
slidCtr = (-time(1)+inputsize/2):stepsize:(time(2)-inputsize/2);