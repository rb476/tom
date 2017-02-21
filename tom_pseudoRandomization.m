function newOrder = tom_pseudoRandomization(expConds, requested)
% newOrder = tom_pseudoRandomization(expConds, requested)
%
% Generates a vector of prompt-question pairs based on 'requested'
% distribution and experimental conditions ('expConds')
%
% Called by tom_writeNewRandomization
%
% See also tom_writeNewRandomization
% 
% rbm 11.15

% [FB,  TB,  FO, TO, DTB]
% requested = [   
%      0     0     0     0     1     10
%      0     1     0     1     0     10
%      0     1     1     0     0     10
%      1     0     0     1     0     10
%      1     0     1     0     0     10];


% requested = [   
%      0     0     0     0     1     1    10
%      0     1     0     1     0     0    20
%      1     0     0     1     0     0    10
%      1     0     1     0     0     0    10];

% requested = [
%      0     0     1     0     1    3
%      0     1     0     1     0    3
%      0     1     1     0     0    3
%      1     0     0     1     0    3
%      1     0     1     0     0    3];
 
 % Restrict array with the requested number of questions of each type
[A,~,C] = unique(expConds(:,4:10),'rows'); % ECOG
% [A,~,C] = unique(expConds(:,4:8),'rows'); % DBS
ferC = findElementRep(C);
locConds = [];%NaN(size(expConds));
for i = 1:size(requested,1)
     thisRow = find(findVectorInMatrix(requested(i,1:end-1), A));
     if ~isempty(thisRow),
         locRand = randperm(ferC(thisRow,2)); % random permutation without replacement
         these = locRand(1:requested(i,end)); % pick the first 'requested' numbers from permutation
         acThese = expConds(C==thisRow,:); % logical indices of prompts
         locConds = [locConds; acThese(these,:)]; % select prompts and append to output
     else
         warning(sprintf('Couldn''t find requested prompt: %s',mat2str(requested(i,1:end-1))))
     end
end

% Pseudorandomize order
[~,~,localC] = unique(locConds(:,4:8), 'rows');
badSeq = 1;
counter = 0;
while badSeq
    counter = counter+1;
    no      = randperm(size(locConds,1));
    badSeq  = sum(diff(locConds(no,2))==0)>0; % NO same trunk two trials in a row
    badSeq  = badSeq + sum(diff(localC(no))==0)>0; % NO same question class two trials in a row
end
newOrder = locConds(no,:);
disp(counter)

% Append a randomization of which question will be asked first
questOrder  = RewardSeqGenerator(50, size(newOrder,1))+1;

newOrder = [newOrder, questOrder];


