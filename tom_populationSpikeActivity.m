% tom_populationSpikeActivity

% Loop all cases

% To obtain the percentage of cells with significant activity...
P = res2ANOVA(:,pvals)<0.05;
[a,~,id]=unique(res2ANOVA(:,5:6),'rows');
perCells = 100*(grpstats(P,id,'mean'));
perCells2ANOVA = [a, perCells];

P = resWRS(:,7:8)<0.05;
perCells = 100*(grpstats(P,id,'mean'));
perCellsWRS = [a, perCells];