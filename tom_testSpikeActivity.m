% Call sliding analysis to perform 2-way ANOVA with interaction on belief
% and falsehood on every unit

time = [2000 2000];
inputsize = 200;
stepsize = 50;
theseSlides = (sum(time)-inputsize+stepsize)/stepsize;
epochTimes = [repmat((1:nTrials)',2,1), qTime_off, ansTime_on];

channels = size(data,2);

res2ANOVA = [];
for ch = 1:channels,
    units = data(ch).HEADER.units;
    for unit = 1:units
        for epoch = 1:2,
            % Obtain bin counts        
            [slidBC, slidCtr] = slidingBinCount(data(ch), unit, ...
                epochTimes(:,[1 1+epoch]), time, ...
                inputsize, stepsize);
            % Perform 2-ANOVA, repeat for each window

            for win = 1:theseSlides
                [P, tbl] = anovan(slidBC(win,:)', ...
                    [belief, falsehood], ...
                    'display','off', 'varnames',{'Belief','Falsehood'}, ...
                    'model','interaction','sstype',1); % NB, sstype=3 results in NaN in falsehood
%                 [P, tbl] = anovan(slidBC(win,:)', ...
%                     [belief, falsehood], ...
%                     'display','off', 'varnames',{'Belief','Falsehood'}, ...
%                     'model','linear','sstype',1); % NB, sstype=3 results in NaN in falsehood
                fxSize = anovaEffectSize(tbl);
                [m, se, n] = grpstats(slidBC(win,:)', ...
                    [belief, falsehood],...
                    {'mean','sem','numel'});
                identifier = [data(1).HEADER.case, data(1).HEADER.session, ...
                    ch, unit, epoch, slidCtr(win)/1000];
                
                res2ANOVA = [res2ANOVA; identifier, P', [tbl{2:4,6}], ...
                    fxSize(1:end-1,3)',...
                    m', se', n'];
%                 res2ANOVA = [res2ANOVA; identifier, P', [tbl{2:3,6}], ...
%                     fxSize(1:end-1,3)',...
%                     m', se', n'];
            end % for windows
        end % for epochs
    end % for units
end % for channels



%% classify responses (more interesting are those around and post answers)



%% Plot each neuron's associated P-value
pvals = 7:9;
[ues,~,unitEpochID] = unique(res2ANOVA(:,3:5),'rows');
epoch = {'Question end','Answer onset'};
figure
for i = 1:length(ues)  
    
    subplot(1,2,ues(i,3))
    plot(repmat(res2ANOVA(unitEpochID==i, 6),1,3), ...
        res2ANOVA(unitEpochID==i, pvals),'linewidth',2)
%     plot(repmat(res2ANOVA(unitEpochID==i, 4),1,3), ...
%         res2ANOVA(unitEpochID==i, 5:7),'linewidth',2)
%     plot(repmat(res2ANOVA(unitEpochID==i, 4),1,2), ...
%         res2ANOVA(unitEpochID==i, 5:6),'linewidth',2)
%     ylim([0 0.1]), xlim([-2 2])
    hold on
    set(gca,'fontsize',14,'tickdir','out')
    ylabel('p-value')
    box off
    ylim([0 0.5])
    
    
%     legend({'Belief','Falsehood'},'location','best')
    xlabel(sprintf('Time around %s (s)', epoch{ues(i,3)}))
    name = sprintf('Ch %d U %d Ep %d prob',ues(i,1),ues(i,2),ues(i,3));
    set(gcf,'name',name)
    title(name)
%     saveMyFigure,close
   
    if ues(i,3)==2,  
        legend({'Belief','Falsehood','B * F'});%,'location','best')
        plot([-time(1), time(2)]./1000, [0.05 0.05],'--k','linewidth',2)

        export_fig(sprintf('ToM Case %d Session %d 2-way ANOVA p values.pdf', ...
            data(1).HEADER.case, data(1).HEADER.session), '-append'),
        subplot(121), cla, 
        subplot(122), cla, 
    else
            plot([-time(1), time(2)]./1000, [0.05 0.05],'--k','linewidth',2)

%         legend({'TO','FO','TB','FB','DTB'})
    end
end
