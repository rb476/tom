% Determine question difficulty in ToM database based on correct
% percentages
qDifficulty = [];

% Loop cases and sessions
for C = 1:5,
    for S = 1:size(allCases(C).session,2),
        if C==5 && S==2,
            continue,
        end
        % extract question ID, Q_order, correct/incorrect/Not asked
        hdr = [];
        hdr = [allCases(C).session(S).trialTypeTable.ID_no, allCases(C).session(S).trialTypeTable.q_order];
        hdr = [hdr; [hdr(:,1), 3-hdr(:,2)]];
        correct = [];
        correct = [allCases(C).session(S).correct(1:2:end);allCases(C).session(S).correct(2:2:end)];    
        qDifficulty = [qDifficulty; hdr, correct];
    end
end

qDifficulty(isnan(qDifficulty(:,3)),3) = 2; % recode isnan /not asked/ as 2

qD = qDifficulty;
qD(qD(:,3)==2,:) = []; % remove questions not asked

% get stats based on each prompt
qD_ID = unique(qD(:,1)); 
[qD_ID_cor, qD_ID_n, qD_ID_mean] = grpstats(qD(:,3), qD(:,1), {'sum','numel','mean'}); 
qD_ID = [qD_ID, qD_ID_cor, qD_ID_n, qD_ID_mean*100];


% get stats based on each prompt-question combination
qD_IDq = unique(qD(:,1:2),'rows');
[qD_IDq_cor, qD_IDq_n, qD_IDq_mean] = grpstats(qD(:,3), qD(:,1:2), {'sum','numel','mean'});
qD_IDq = [qD_IDq, qD_IDq_cor, qD_IDq_n, qD_IDq_mean*100];

difficulty = zeros(length(qD_IDq),1);
difficulty(qD_IDq(:,5)==0)      = 4;
difficulty(qD_IDq(:,5)<66  & qD_IDq(:,5)>0)    = 3; % 10th percentile
difficulty(qD_IDq(:,5)>=66 & qD_IDq(:,5)<=81) = 2; % >10th & < 25th percentile
difficulty(qD_IDq(:,5)>81)    = 1;

qD_IDq = [qD_IDq, difficulty];