function res2ANOVA = tom_testSpikeActivity(data, typeOfPlot, params)
% Call sliding analysis to perform 2-way ANOVA with interaction on belief
% and falsehood on every unit
%
% typeOfPlot = 'fxSz';
% 

% 2-way ANOVA w/o interaction
pvals = 7:8;
fxSz =  11:12;
mfr = 13:16; 

% if nargin==3,
    time = [2000 2000];
    inputsize = 200;
    stepsize = 50;    
% else
%     time = params.time;
%     inputsize = params.inputsize;
%     stepsize = params.stepsize;    
% end



theseSlides = (sum(time)-inputsize+stepsize)/stepsize;
Q = data.transcription.Question==1;
qTime_off  = data.transcription.End(Q);
ansTime_on = data.transcription.Start(find(Q)+1);
epochTimes = round([qTime_off, ansTime_on]*1000); % in ms
anovaFactors = [data.belief, data.falsehood];
anovaFactors(sum(isnan(anovaFactors),2)>0,:) = []; % remove NaNs

res2ANOVA = [];
for ch = 1:5,
    units = size(data.channel(ch).unit,2);    
    if ~isempty(units),
        for unit = 1:units
            spikeTS = round(data.channel(ch).unit(:,unit).ts*1000); % in ms
            for epoch = 1:2,
                % Obtain bin counts        
                [slidBC, slidCtr] = tom_slidingBinCount(spikeTS, ...
                    epochTimes(:, epoch), time, inputsize, stepsize);
                
                % Perform 2-ANOVA, repeat for each window
                for win = 1:theseSlides
                    [P, tbl] = anovan(slidBC(win,:)', ...
                        anovaFactors, ...
                        'display','off', 'varnames',{'Belief','Falsehood'}, ...
                        'model','linear','sstype',1); % NB, sstype=3 results in NaN in falsehood
                    fxSize = anovaEffectSize(tbl);
                    [m, se, n] = grpstats(slidBC(win,:)', anovaFactors,...
                        {'mean','sem','numel'});
                    identifier = [data.case, data.session, ...
                        ch, unit, epoch, slidCtr(win)/1000];

                    res2ANOVA = [res2ANOVA; identifier, P', [tbl{2:3,6}], ...
                        fxSize(1:end-1,3)',...
                        m', se', n'];
                end % for windows
            end % for epochs
        end % for units
    end % if units
end % for channels

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
