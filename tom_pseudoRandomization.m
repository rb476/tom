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
requested = [   
     0     0     0     0     1     10
     0     1     0     1     0     10
     0     1     1     0     0     10
     1     0     0     1     0     10
     1     0     1     0     0     10];


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
[A,~,C] = unique(expConds(:,4:end),'rows');
ferC = findElementRep(C);
locConds = [];%NaN(size(expConds));
 for i = 1:size(requested,1)
     locRand = randperm(ferC(i,2));
     these = locRand(1:requested(i,end));
     acThese = expConds(C==i,:);
     locConds = [locConds; acThese(these,:)]; 
 end

% sequence in which the nodes don't follow each other
badSeq = 1;
counter = 0;
while badSeq
    counter = counter+1;
    no = randperm(size(locConds,1));
    badSeq = sum(diff(locConds(no,1),2)==0)>0;
end
newOrder = locConds(no,:);
disp(counter)

% Append a randomization of which question will be asked first
questOrder  = RewardSeqGenerator(50, sum(requested(:,end)))+1;

newOrder = [newOrder, questOrder];


