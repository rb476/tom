function output = tom_testSpikeActivity(data, typeOfPlot, params)
% Call sliding analysis to perform statistial test on belief
% and falsehood on every unit
% Performs: 2-way ANOVA, Wilcoxon ranksum, AUROC w/permutation test
%
% In:
% 
% data, 'session data structure'
%
% typeOfPlot = 'fxSz';'pval,'meanFR'
%
% params.time         = [2000 2000];
% params.inputsize    = 250;
% params.stepsize     = 25;
% Make stepsize=inputsize to perform 'fixed window analyses'  
%
% See also tom_loopNeuronalAnalyses
%
% rbm 5.16

% 2-way ANOVA w/o interaction
pvals = 7:8;
fxSz =  11:12;
mfr = 13:16;


time = params.time;
inputsize = params.inputsize;
stepsize = params.stepsize;

% Initialization
theseSlides = (sum(time)-inputsize+stepsize)/stepsize;
res2ANOVA = [];
resWRS = [];
roc_fb = [];
resReg = [];

% Find Q&A times
Q = data.transcription.Question==1;
qTime_off  = data.transcription.End(Q);
ansTime_on = data.transcription.Start(find(Q)+1);
epochTimes = round([qTime_off, ansTime_on]*1000); % in ms

if size(epochTimes,1)~=100,
    % use second method,
    epochTimes = round([data.qTime_off, data.ansTime_on]*1000); % in ms
end

% Grouping factors
anovaFactors = [data.belief, data.falsehood];
cats = data.qCatVec;
nQ = length(anovaFactors);
complexity = NaN(nQ,1);
C = data.PromptLangAnalysisTable.Complexity;
if iscell(C), C = [C{:}]; end
complexity(1:2:(length(C)*2)) = C;
complexity(2:2:(length(C)*2)) = C; 

WC = zeros(nQ,1);
wc = data.QuestOneLangAnalysisTable.WC;
if iscell(wc), 
    WC(1:2:end) = [wc{:}];
    WC(2:2:end) = [data.QuestTwoLangAnalysisTable.WC{:}]; 
else
    WC(1:2:(length(wc)*2)) = wc;
    WC(2:2:(length(data.QuestTwoLangAnalysisTable.WC)*2)) = data.QuestTwoLangAnalysisTable.WC; 
end

qOrder = ones(nQ,1);
qOrder(2:2:end) = 2;


% remove NaNs, which are placeholders for planned Q that weren't asked
remThese = zeros(length(epochTimes),1);
remThese(data.correct==0) = 1;
remThese(isnan(epochTimes(:,1))) = 1;
remThese = remThese==1;

% Only analyze correct responses (although interesting, behavioural errors 
%   are ~10%)
if (length(epochTimes)~=length(complexity)) | length(epochTimes)~=length(WC) | length(epochTimes)~=length(qOrder),
    keyboard
end
epochTimes(remThese,:)  =[];
anovaFactors(remThese,:)= [];
% cats(remThese)          = [];
complexity(remThese)    = [];
WC(remThese)            = [];
qOrder(remThese)        = [];

% designMatrix = [ones(length(anovaFactors),1), anovaFactors, ...
%     anovaFactors(:,1).*anovaFactors(:,2)];
designMatrix = [ones(length(anovaFactors),1), anovaFactors, ...
    anovaFactors(:,1).*anovaFactors(:,2), complexity, WC, qOrder];


for ch = 1:5,
    units = size(data.channel(ch).unit,2);    
    if ~isempty(units),
        for unit = 1:units
            spikeTS = round(data.channel(ch).unit(:,unit).ts*1000); % in ms
            for epoch = 1:2,                                                               
                % Obtain bin counts        
                [slidBC, slidCtr] = tom_slidingBinCount(spikeTS, ...
                    epochTimes(:, epoch), time, inputsize, stepsize);
                
                if size(slidBC,2)~=size(anovaFactors,1)
                    warning('Problem at tom_testSpikeActivity')
                    keyboard
                end
                
                              
                % repeat for each window
                for win = 1:theseSlides
                    identifier = [data.case, data.session, ...
                        ch, unit, epoch, slidCtr(win)/1000];

                    % Perform 2-ANOVA, 
%                     [P, tbl] = anovan(slidBC(win,:)', anovaFactors, ...
%                         'display','off', 'varnames',{'Belief','Falsehood'}, ...
%                         'model','linear','sstype',1); % NB, sstype=3 results in NaN in falsehood
                    [P, tbl] = anovan(slidBC(win,:)', anovaFactors, ...
                        'display','off', 'varnames',{'Belief','Falsehood'}, ...
                        'model','interaction','sstype',1); % NB, sstype=3 results in NaN in falsehood
                    fxSize = anovaEffectSize(tbl);
                    [m, se, n] = grpstats(slidBC(win,:)', anovaFactors,...
                        {'mean','sem','numel'});
                                        

%                     res2ANOVA = [res2ANOVA; identifier, P', [tbl{2:3,6}], ...
%                         fxSize(1:end-1,3)',...
%                         m', se', n'];
                    res2ANOVA = [res2ANOVA; identifier, P', [tbl{2:4,6}], ...
                        fxSize(1:end-1,3)',...
                        m', se', n'];
                    
                    % MLR with dummy variables
                    
                    rs_temp = regstats(slidBC(win,:), designMatrix, ...
                        eye(size(designMatrix,2)), {'tstat','beta','rsquare', 'fstat'});
%                     [rho, pval] = partialcorr([slidBC(win,:), designMatrix(:,2:end)],designMatrix(:,2:end));
                    resReg = [resReg; identifier, rs_temp.tstat.pval(2:end)', rs_temp.beta(2:end)'];
                    
                    
                    % Wilcoxon rank sum/umw
%                     prs_b = ranksum(slidBC(win,cats==1), slidBC(win,cats==4));%FB vs. FO
%                     prs_f = ranksum(slidBC(win,cats==1), slidBC(win,cats==2)); %FB vs. TB
%                     resWRS = [resWRS; identifier, prs_b, prs_f];
                    
                    % ROC                   
%                     IN = [slidBC(win,cats==2)'; slidBC(win,cats==1)'];
%                     labs = [zeros(sum(cats==2),1); ones(sum(cats==1),1)];
%                     [permP, oSt] = permutationTest(IN, labs, 'ROCsk', 500, 0);
%                     roc_fb  = [roc_fb; identifier, permP, oSt];
                    
                end % for sliding windows
            end % for epochs
        end % for units
    end % if units
end % for channels

%% All output
output.resReg = resReg;
output.res2ANOVA = res2ANOVA;
% output.wrs = resWRS;
% output.roc_fb = roc_fb;

%% classify responses (more interesting are those around and post answers)



%% Plot each neuron's associated P-value/effect size/mean FR
if isempty(typeOfPlot)
    return
end

[ues,~,unitEpochID] = unique(res2ANOVA(:,3:5),'rows');
epoch = {'Question end','Answer onset'};
figure
for i = 1:length(ues)  
    
    subplot(1,2,ues(i,3))
    
    switch typeOfPlot
        case 'pval',
            % Plot P-value
            plot(repmat(res2ANOVA(unitEpochID==i, 6),1,length(pvals)), ...
                res2ANOVA(unitEpochID==i, pvals),'linewidth',2)
            ylabel('p-value')
            legend({'Belief','Falsehood'},'location','best')
            ylim([0 0.5])
        case 'fxSz'
            plot(repmat(res2ANOVA(unitEpochID==i, 6),1,length(fxSz)), ...
                res2ANOVA(unitEpochID==i, fxSz),'linewidth',2)
            legend({'Belief','Falsehood'},'location','best')
            ylabel 'Effect Size (a.u.)'
        case 'meanFR'
            plot(repmat(res2ANOVA(unitEpochID==i, 6),1,length(mfr)), ...
                res2ANOVA(unitEpochID==i, mfr),'linewidth',2)
             legend({'TO','FO','TB','FB'},'location','best')
             ylabel 'Firing Rate (sp/s)'
    end

    hold on
    set(gca,'fontsize',14,'tickdir','out')
    box off
   
    xlabel(sprintf('Time around %s (s)', epoch{ues(i,3)}))
    name = sprintf('Ch %d U %d Ep %d prob',ues(i,1),ues(i,2),ues(i,3));
    set(gcf,'name',name)
    title(name)
   
    if ues(i,3)==2,  
        legend({'Belief','Falsehood','B * F'});%,'location','best')
        plot([-time(1), time(2)]./1000, [0.05 0.05],'--k','linewidth',2)

        export_fig(sprintf('ToM Case %d Session %d 2-way ANOVA %s.pdf', ...
            data.case, data.session, typeOfPlot), '-append'),
        subplot(121), cla, 
        subplot(122), cla, 
    else
        plot([-time(1), time(2)]./1000, [0.05 0.05],'--k','linewidth',2)
    end
end
