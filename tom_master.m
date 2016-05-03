%% File names
preHeader.case    = 1;
preHeader.session = 1;

xls_page = 'Randomization 1'; % This needs to be changed manually
xls_file = sprintf('prompts list db case %d answers.xlsx', preHeader.case);
spk_file = sprintf('neurons case %d session %d',preHeader.case, preHeader.session);
lfp_file = sprintf('LFP case %d session %d',preHeader.case, preHeader.session);
audio_file = sprintf('prompt times case %d session %d',preHeader.case, preHeader.session);

%% Load tags for the prompts, preliminary description of behaviour
tom_summarySingle;
openvar answersTbl

%% load spike times
spks = load(spk_file);
% Load LFP 
lfp = load(lfp_file);

fld = fields(spks);
for f = 1:5,
    if ~isempty(spks.(fld{f}))
        chSpk = spks.(fld{f});
        unitsInCh = length(unique(chSpk(:,2)));
        for jj = 1:unitsInCh
            unit = chSpk(:,2)==jj;
            preHeader.channel(f).unit(jj).ts = chSpk(unit,3);
        end
    end
    preHeader.channel(f).lfp = lfp.all_samples(f,:);
end

%% Load audio times
load(audio_file)

%% prepare data header
preHeader.animal    = preHeader.case;
preHeader.trialType = ans_no(:,1:10);
preHeader.answers   = ans_no(:,[15 17]);
preHeader.trialNo   = size(ans_no,1);
preHeader.audio     = audio;
preHeader.fs_spike  = 44000;    % Hz
preHeader.fs_lfp    = 1375;     % Hz
preHeader.fs_audio  = 22000;    % Hz

preHeader.trialTypeTable = array2table(preHeader.trialType,'VariableNames', ...
    {'TrialNo','IDNo','Trunk','Branch','False_belief','true_belief','false_object',...
    'true_object','dbl_true_belief','Q_order'});
% preHeader.trialTimes_Spl = trialTimes;
% preHeader.trialTimes_Sec = trialTimes/fs;
% preHeader.BHV       = BHV;

% audTimesSpl = [BHV.Segment];
% trialTimes = reshape(audTimesSpl(1,:),2,length(audTimesSpl(1,:))/2)';
% preHeader.trialTimes_Spl(:,1)  = audTimesSpl(1,1:2:end)';
% preHeader.trialTimes_Spl(:,2)  = max(audTimesSpl(:,2:2:end));
% preHeader.trialTimes_Sec  = preHeader.trialTimes_Spl/fs;
% preHeader.BHV       = BHV;

%% Event times, question-type matrix, belief, falsehood indicator functions
%%%% end of question, start of answer
nTrials = size(ans_no,1);

% allTimes = [preHeader.BHV.Segment]./11000;
% allTimes = [preHeader.BHV.promptTimes]./preHeader.fs_audio;

% trStart = repmat(allTimes(1,1:2:end)',2,1);
% 
% qTime_off = allTimes([2 4], 2:2:end);
% qTime_off = reshape(qTime_off', nTrials*2, 1)-trStart;
% qTime_off = round(qTime_off*1000); 
% 
% ansTime_on = allTimes([3 5],1:2:end);
% ansTime_on = reshape(ansTime_on', nTrials*2, 1)-trStart;
% ansTime_on = round(ansTime_on*1000);

correct = reshape(preHeader.answers', nTrials*2, 1);
%% Populate a question-type matrix by brute force
% FB=1, TB=2, DTB=3, FO=4, TO=5
qCat = zeros(nTrials,2);
for i = 1:nTrials,
    if ans_no(i,5),
        qCat(i,ans_no(i,10)) = 1;
    elseif ans_no(i,6)
        qCat(i,ans_no(i,10)) = 2;
    elseif ans_no(i,9)
        qCat(i,ans_no(i,10)) = 3;
    end
    if ans_no(i,7),
        qCat(i,3-ans_no(i,10)) = 4;
    elseif ans_no(i,8)
        qCat(i,3-ans_no(i,10)) = 5;
    end
end
qCatVec = reshape(qCat, nTrials*2, 1);

% populate matrix with belief/object and truthood/falsehood as factors
belief     = single(findIndicesInVector(qCatVec, [1 2]));
belief(qCatVec==3) = 2; 
% belief     = single(findIndicesInVector(qCatVec, [1 2 3]));
% belief = belief(correct==1);
% falsehood  = single(findIndicesInVector(qCatVec(correct==1), [1 4]));
falsehood  = single(findIndicesInVector(qCatVec, [1 4]));
% preHeader.qTime_off     = qTime_off;
% preHeader.ansTime_on    = ansTime_on;
preHeader.belief        = belief;
preHeader.falsehood     = falsehood;
preHeader.qCatVec       = qCatVec;


%% Append transcription to header
% F = fopen('C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\Case 1\words_case1_session1(3).txt','r');
F = fopen('C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\Case 2\Depth2\words case 2 session 2.txt','r');

M = textscan(F, '%f %f %s');
fclose(F);
t = array2table([M{1},M{2}],'VariableNames',{'Start','End'});
t2 = array2table(M{3},'VariableNames',{'Words'});
t3 = horzcat(t, t2);

% Determine who spoke
noWords = height(t);
pqa = zeros(noWords,1);
lastPunct = '.'; 
last = 1; modifier = 0; 
question = zeros(noWords,1);
for i = 2:noWords,
    w = t3.Words(i);
    fs = strfind(w,'.');
    fp = strfind(w,'?');
    if ~isempty(fs{:})
        pqa(last:i) = 1+modifier;
        last = i+1;
        modifier = 0;
    elseif ~isempty(fp{:})
        question(i) = 1;
        pqa(last:i) = 2;
        last = i+1;
        modifier = 2;
    end
end
% obtain actor. Subject only speaks after a question.
actor = ones(length(pqa),1);
actor(pqa==3) = 2;
t4 = array2table([pqa, actor, question],'VariableNames',{'Sentence','Speaker', 'Question'});
t5 = horzcat(t3,t4);

% obtain prompt number
dpqa = diff(pqa);
dpqa = [0; dpqa];
pid = cumsum(dpqa==-2);
t6 = horzcat(t5, array2table(pid+1,'VariableNames',{'Prompt'}));

preHeader.transcription = t6;
%% finish preparing dataset
% tomCase(preHeader.case).session(preHeader.session) = preHeader;
tomCase.session(preHeader.session) = preHeader;

fprintf('tom_master done!\n')
return

%% ---->>> Latency to answer? (parsed by question category)
% tom_responseLatency

%% Basic statistical tests on spike activity
tom_testSpikeActivity;

%% LFP analysis
% tom_lfpAnalysis(dataLFP)

%% Let's get plotting!
channels = size(data,2);
for ch = 1:channels,
    units = data(ch).HEADER.units;
    for unit = 1:units
        tom_plotRasters;
    end
end