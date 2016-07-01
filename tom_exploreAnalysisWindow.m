% test different window sizes
tic
params.time = [4000 4000];
allInputSize = 200:200:3000;
params.stepsize = 100;
pThr = 0.05;

matToPlot = zeros(numel(allInputSize),...
    (sum(params.time)-allInputSize(1)+params.stepsize)/params.stepsize, 6);
res = [];
matToPlot_wrs = zeros(size(matToPlot));
res_wrs = [];

h = waitbar(0,'Please wait...');hc=0;

for isz = 1:numel(allInputSize),
    params.inputsize = allInputSize(isz);
%     params.stepsize = params.inputsize;
    output.wrs = [];
    output.anova2 = [];
    output.roc = [];

    for i = 1:5,
        for ii = 1:size(allCases(i).session,2),
            sessionoutput = tom_testSpikeActivity(allCases(i).session(ii), [], params); 
            if isz==1 && i==1 && ii ==1
                X = unique(sessionoutput.res2ANOVA(:,6));
            end
%             output.wrs = [output.wrs; sessionoutput.wrs];
            output.anova2 = [output.anova2; sessionoutput.res2ANOVA];
            hc = hc+1;
            waitbar(hc/(numel(allInputSize)*9), h)
        end    
    end
    
    [a,b,nId]=unique(output.anova2(:,1:4),'rows');
%     X = unique(output.anova2(:,6));
    Yper = [];Yper2=[];
    for j = 1:2,
        for jj = 7:9,
%             if jj < 9,
%             % Rank-sum
%                 Y = reshape(output.wrs(output.wrs(:,5)==j,jj), length(X), length(a));
%                 Y(Y>pThr) = pThr;
%                 Y(isnan(Y)) = pThr;
%                 Yper2 = [Yper2, mean(Y<pThr,2)*100];
%             end
            %2-way ANOVA
            X = unique(output.anova2(:,6));
            Y = [];
            Y = reshape(output.anova2(output.anova2(:,5)==j,jj), ...
                    length(X), length(a));
             Y(Y>pThr) = pThr;
            Y(isnan(Y)) = pThr;
            Yper = [Yper, mean(Y<pThr,2)*100];
        end
    end
    
    res(isz).res = [X, Yper];
    matToPlot(isz, 1:size(Yper,1), :) = Yper;
    
%     res_wrs(isz).res = [X, Yper2];
%     matToPlot_wrs(isz, 1:size(Yper2,1), 1:4) = Yper2;
end
save('windowSizeExploration_zscore_tom','res','matToPlot');%,'res_wrs','matToPlot_wrs')
toc
%% plot results
% t =  {'Q Belief','Q False','A belief', 'A false'};
t =  {'Q Belief','Q False','Q B-F','A belief', 'A false','A B-F'};
% t = {'Q FB vs. FO','Q FB vs. TB','A FB vs. FO', 'A FB vs. TB'};
X = res(1).res(:,1);
for k = 1:6,    
%     X = res(isz).res(:,1);
    figure
%     imagesc(squeeze(matToPlot(:,:,k)), 'XData', X, 'YData', allInputSize)
    aligRes = NaN(79,15);
    for kk = 1:15,
        aligRes(findIndicesInVector(res(1).res(:,1),res(kk).res(:,1)),kk) = res(kk).res(:,k+1);
    end
    imagesc(aligRes', 'XData', X, 'YData', allInputSize)
    title(t(k))
    if k <4
        xlabel 'Question end (s)'
    else
        xlabel 'Answer onset (s)'
    end
    ylabel 'Window size (ms)'
    colorbar
    set(gcf,'name',['an2 tom slid win expl ', t{k}])
%     saveMyFigure
end