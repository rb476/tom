% function tom_responseLatenc(sessionData)
%
% Estimate latency to respond in the ToM task
%
% rbm 15-16
Sess = 1;
Q = tomCase.session(Sess).transcription.Question==1;

qTime_off  = tomCase.session(Sess).transcription.End(Q);
ansTime_on = tomCase.session(Sess).transcription.Start(find(Q)+1);
belief     = tomCase.session(Sess).belief;
falsehood  = tomCase.session(Sess).falsehood;
correct    = tomCase.session(Sess).correct;
% correct = reshape(tomCase.session.answers',length(tomCase.session.answers)*2,1);

% Returns latency to answer in ToM task, performs a 2-way ANOVA
latency = ansTime_on - qTime_off;
corrNoNaN = correct;
corrNoNaN(isnan(correct)) = [];
latency = latency(corrNoNaN==1);
factors = [belief, falsehood];
factors = factors(corrNoNaN==1,:);
% factors = factors(correct==1,:);

% Perform 2-way anova with interaction
[P_lat, table_lat, stat_lat] = anovan(latency, factors, ...
    'display','off', 'varnames',{'Belief','Falsehood'}, ...
    'model','interaction','sstype',1); % NB, sstype=3 results in NaN in falsehood
fxSize_lat = anovaEffectSize(table_lat);
[mB_lat, seB_lat, nB_lat] = grpstats(latency, factors(:,1), {'mean','sem','numel'});
catSumBelief = [mB_lat, seB_lat, nB_lat];


% We can also ask at a basic level between categories w/ 1-way ANOVa
[p_lat_1, t_lat_1, stats_lat_1] = anova1(latency, qCatVec(correct==1),'off');
mc1=multcompare(stats_lat_1);
[mB_latc, seB_latc, nB_latc] = grpstats(latency, qCatVec(correct==1), {'mean','sem','numel'});
catSum = [mB_latc, seB_latc, nB_latc];
%%
figure
subplot(221)    
barWithCI(1:3, mB_lat, seB_lat, 'k', 'linewidth', 2)
set(gca, 'xticklabel', {'Object','Belief','Double Belief'})
box off
ylabel 'Answer latency (ms)'

subplot(222)
boxplot(latency, belief(correct==1))
set(gca, 'xticklabel', {'Object','Belief','Double Belief'})
box off,
ylabel 'Answer latency (ms)'

subplot(223)
boxplot(latency, qCatVec(correct==1))
set(gca,'xticklabel',{'FB','TB','DTB','FO','TO'})
box off,
ylabel 'Answer latency (ms)'

annotatePlot(sprintf('Case %d Session %d', preHeader.case, preHeader.session));