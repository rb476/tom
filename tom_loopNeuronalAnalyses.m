%% Loop each recorded session, perform 2-anova and WRS running window analyses, 
% append results
params.time = [3000 3000];
params.inputsize = 1000;
params.stepsize = 1000;

output.wrs = [];
output.anova2 = [];
output.roc = [];
output.nameswrs = [];
output.mlr = [];

for i = 1:5,
    if ~isempty(allCases(i))
        for ii = 1:size(allCases(i).session,2),
            sessionoutput = tom_testSpikeActivity(allCases(i).session(ii), [], params);            
            output.mlr = [output.mlr; sessionoutput.resReg];
%             output.wrs = [output.wrs; sessionoutput.wrs];
%             output.anova2 = [output.anova2; sessionoutput.res2ANOVA];
%             output.roc = [output.roc; sessionoutput.roc_fb];

%              out = tom_testSpikeNames(allCases(i).session(ii), params);
%              output.nameswrs = [output.nameswrs; out.rs];
        end
    end
end

%% Summary tables
mlrThrP = output.mlr(:,10:12)<0.05;
mlrThrPclass = zeros(length(output.mlr),1);
mlrThrPclass(mlrThrP(:,1)==0 & mlrThrP(:,2)==1) = 1;
mlrThrPclass(mlrThrP(:,1)==1 & mlrThrP(:,2)==0) = 2;
% mlrThrPclass((mlrThrP(:,1)==1 & mlrThrP(:,2)==1) | mlrThrP(:,3)==1) = 3;
% mlrThrPclass(mlrThrP(:,1)==1 & mlrThrP(:,2)==1) = 3;
mlrThrPclass(mlrThrP(:,1)==1) = 3;


ts = unique(output.mlr(:,6));
counter = zeros(length(ts),3,2);
for i = 1:length(ts),
    for ii = 1:3,
        for iii = 1:2,
            th = mlrThrPclass(output.mlr(:,5)==iii & output.mlr(:,6)==ts(i))==ii;
            if ~isempty(th),
                counter(i, ii, iii) = sum(th);
            end
        end
    end
end
figure,
subplot(1,2,1), plot(ts,counter(:,:,1),'linewidth',2),box off, 
ylabel 'Significant neurons (%)'
xlabel 'Question offset (s)'

subplot(1,2,2),plot(ts,counter(:,:,2),'linewidth',2),box off
legend({'Belief','Falsehood','Both'})
xlabel 'Answer onset (s)'

% % [A,~,nClassID] = unique([output.mlr(:,5:6), mlrThrPclass],'rows');
% [A,~,nClassID] = unique([output.mlr(:,5:6), mlrThrPclass],'rows');
% fer = findElementRep(nClassID);
% % sumTbl = array2table([A, fer(:,2)],'VariableNames',{'Epoch','time','belief','false','n'});
% 
% sumTbl = array2table([A, fer(:,2), 100*(fer(:,2)./95)],'VariableNames',{'Epoch','time','class','n','nPer'});
% sumTbl(sumTbl.class==0,:) = [];

%% Generate a heatmap for each combination of epoch and facotr/comparison
pThr = 0.05;
resToPlot = 'anova2';
[a,b,nId]=unique(output.anova2(:,1:4),'rows');
X = unique(output.anova2(:,6));
Yper = [];
anTt = sprintf('Win=%d step=%d',params.inputsize, params.stepsize);
figure
n=0;
for j = 1:2,
    for jj = 7:9,
        n = n+1;
        subplot(2,3,n)
        switch resToPlot
            case 'auroc'
%                 AUROC
                 Y = reshape(output.roc(output.wrs(:,5)==j,8), length(X), length(a));
                 p = reshape(output.roc(output.wrs(:,5)==j,7), length(X), length(a));
                 Y(p>0.025 & p<0.975) = 0.5;
                 Y(Y<0.5) = Y(Y<0.5)+0.5;
                 Yper = [Yper, mean(Y~=0.5,2)*100];
            case 'rs',
                % Rank-sum
                Y = reshape(output.wrs(output.wrs(:,5)==j,jj), length(X), length(a));
                 Y(Y>pThr) = pThr;
                Y(isnan(Y)) = pThr;
                Yper = [Yper, mean(Y<pThr,2)*100];
            case 'anova2'
                % 2-way ANOVA
                Y = reshape(output.anova2(output.anova2(:,5)==j,jj), ...
                    length(X), length(a));
                 Y(Y>pThr) = pThr;
                Y(isnan(Y)) = pThr;
                Yper = [Yper, mean(Y<pThr,2)*100];
        end
        
       
               
        lat = zeros(length(a),1);
        for i = 1:length(a),   
            if strcmpi('auroc',resToPlot)
                preLat =  find(((Y(:,i)-0.5)~=0),1); % AUROC
            else
                preLat =  nanmin(find(Y(:,i)<pThr));
            end
            
            if ~isempty(preLat),
                lat(i) = preLat;
            end
        end
        Y(:,lat==0)=[];
        lat(lat==0) = [];
        [~,minLatID] = sort(lat,'descend');
        sY = Y(:,minLatID);
%         figure
%         imagesc(sY');
        imagesc(sY', 'XData', X, 'YData', 1:size(Y,2))
       
        C = colormap;
         C(end,:) = ones(3,1);
%         C(1,:) = ones(3,1);
        colormap(C)
%         colormap('hot')
        
        colorbar
        ylabel 'Neuron #'
        S = {'Question end','Answer start'};
        xlabel(sprintf('Time aligned to %s (s)',S{j}))
        if jj==7,
%             title 'Thresholded p-value FB vs FO rs'
            title 'Thresh p-val Belief'
%             title 'Rectified AUROC'
        elseif jj ==8 
%             title 'Thresholded p-value FB vs TB rs'
            title 'Thresh p-val Falsehood'
%              title 'Rectified AUROC'
        else
            title 'Thresh p-val B-F'
        end
        annotatePlot(anTt);
    end
end

%%
figure
plot(repmat(X,1,size(Yper,2)), Yper,'linewidth',2)
set(gca,'fontsize',12,'tickdir','out')
xlabel 'Time (s)'
ylabel '% of significant neurons'
box off
% title 'from rs'
title 'from 2-way ANOVA'
if size(Yper,2)==4,
    legend({'Q Belief','Q False','A belief', 'A false'})
%     legend({'Q FB vs. FO','Q FB vs. TB','A FB vs. FO', 'A FB vs. TB'})
elseif size(Yper,2)==6,
    legend({'Q Belief','Q False', 'Q BF', 'A belief', 'A false', 'A BF'})
else
    legend({'Question','Answer'})
end
annotatePlot(anTt);