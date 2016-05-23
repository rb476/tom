%% File names
preHeader.case    = 3;
preHeader.session = 2;

xls_page = 'Randomization 6'; % This needs to be changed manually
xls_file = sprintf('prompts list db case %d answers.xlsx', preHeader.case);
spk_file = sprintf('neurons case %d session %d',preHeader.case, preHeader.session);
lfp_file = sprintf('LFP case %d session %d',preHeader.case, preHeader.session);
if preHeader.case >= 4
    audio_file = sprintf('session audio case %d session %d.wav',preHeader.case, preHeader.session);
else
    audio_file = sprintf('prompt times case %d session %d',preHeader.case, preHeader.session);
end
wordsFile = sprintf('words case %d session %d.txt',preHeader.case, preHeader.session);

%% Load tags for the prompts, preliminary description of behaviour
tom_summarySingle;
% openvar answersTbl

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
if preHeader.case >= 4
    audio = audioread(audio_file);
    preHeader.answers   = ans_no(:,[13 16]);
else
    load(audio_file)
    preHeader.answers   = ans_no(:,[14 16]);
end


%% prepare data header
preHeader.animal    = preHeader.case;
% 
preHeader.trialNo   = size(ans_no,1);
preHeader.trialTypeTable = cell2table(ans_all(2:end,1:9),'VariableNames',ans_all(1,1:9));
preHeader.audio     = audio;
preHeader.fs_spike  = 44000;    % Hz
preHeader.fs_lfp    = 1375;     % Hz
preHeader.fs_audio  = 22000;    % Hz

%% Event times, question-type matrix, belief, falsehood indicator functions
nTrials = size(ans_no,1);
preHeader.correct = reshape(preHeader.answers', nTrials*2, 1);

%% Populate a question-type matrix by brute force
% FB=1, TB=2, DTB=3, FO=4, TO=5
qCat = NaN(nTrials,2);
T =  preHeader.trialTypeTable;
for i = 1:nTrials,
    if T.false_belief(i)==1,
        qCat(i,T.q_order(i)) = 1;
    elseif T.true_belief(i)==1
        qCat(i,T.q_order(i)) = 2;
    elseif T.dbl_true_believe(i)==1
        qCat(i,T.q_order(i)) = 3;
    end
    
    if T.false_object(i)==1,
        qCat(i,3-T.q_order(i)) = 4;
    elseif T.true_object(i)==1,
        qCat(i,3-T.q_order(i)) = 5;
    end
end
qCatVec = reshape(qCat, nTrials*2, 1);

% populate matrix with belief/object and truthood/falsehood as factors
preHeader.belief = NaN(100,1);
preHeader.belief(qCatVec <= 3) = 1;
preHeader.belief(qCatVec > 3) = 0;

preHeader.falsehood = NaN(100,1);
preHeader.falsehood(qCatVec == 1 | qCatVec == 4) = 1;
preHeader.falsehood(qCatVec == 2 | qCatVec == 3 | qCatVec == 5) = 0;

preHeader.qCatVec = qCatVec;

%% Append transcription to header
F = fopen(wordsFile,'r');

M = textscan(F, '%f %f %s');
% remove empty strings
m = [M{1,3}];
for i = 1:length(m),
    rt(i) = isempty(m{i});
end

fclose(F);
t = array2table([M{1},M{2}]/10000000,'VariableNames',{'Start','End'});
% t = array2table([M{1},M{2}],'VariableNames',{'Start','End'});

t2 = array2table(M{3},'VariableNames',{'Words'});
t3 = horzcat(t, t2);
t3(rt==1,:) = []; 

% Determine who spoke
noWords = height(t3);
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
t4 = array2table([pqa, actor, question],'VariableNames',...
    {'Sentence','Speaker', 'Question'});
t5 = horzcat(t3,t4);

% obtain prompt number
dpqa = diff(pqa);
dpqa = [0; dpqa];
pid = cumsum(dpqa==-2);
t6 = horzcat(t5, array2table(pid+1,'VariableNames',{'Prompt'}));

preHeader.transcription = t6;

%% Get main event timings
Q           = t6.Question==1;
promptStart = [1; find(diff(t6.Sentence)==-2)+1];
promptEnd   = find(diff(t6.Sentence)==1 & t6.Speaker(2:end)==1);
ansEndFirstQ= find(diff(t6.Sentence)==-1);

preHeader.prompt_on     = t6.Start(promptStart);
preHeader.prompt_off    = t6.End(promptEnd);

qTime_on  = sort([t6.Start(promptEnd+1); ...
                    t6.Start(ansEndFirstQ+1)]);
qTime_off  = t6.End(Q);
ansTime_on = t6.Start(find(Q)+1);
ansTime_off = sort([t6.End(promptStart(2:end)-1); ...
                              t6.End(ansEndFirstQ); t6.End(end)]);
                          
% Reshape to insert NaNs for questions not asked....
preHeader.qTime_on = NaN(100,1);
preHeader.qTime_on(~isnan(preHeader.correct)) = qTime_on;
preHeader.qTime_off = NaN(100,1);
preHeader.qTime_off(~isnan(preHeader.correct)) = qTime_off;
preHeader.ansTime_on = NaN(100,1);
preHeader.ansTime_on(~isnan(preHeader.correct)) = ansTime_on;
preHeader.ansTime_off = NaN(100,1);
preHeader.ansTime_off(~isnan(preHeader.correct)) = ansTime_off;

%% finish preparing dataset
tomCase.session = preHeader;
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