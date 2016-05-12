%% Loop each recorded session, perform 2-anova and WRS running window analyses, 
% append results
params.time = [2000 2000];
params.inputsize = 200;
params.stepsize = 25;

output.wrs = [];
output.anova2 = [];
output.roc = [];
for i = 1:length(allCases),
    if ~isempty(allCases(i))
        for ii = 1:size(allCases(i).session,2),
            sessionoutput = tom_testSpikeActivity(allCases(i).session(ii), [], params);            
            output.wrs = [output.wrs; sessionoutput.wrs];
            output.anova2 = [output.anova2; sessionoutput.res2ANOVA];
            output.roc = [output.roc; sessionoutput.roc_fb];
        end
    end
end



%% Generate a heatmap for each combination of epoch and facotr/comparison
[a,b,nId]=unique(output.wrs(:,1:4),'rows');
X = unique(output.wrs(:,6));
Yper = [];
anTt = sprintf('Win=%d step=%d',params.inputsize, params.stepsize);
for j = 1:2,
%     for jj = 7:8,
         Y = reshape(output.roc(output.wrs(:,5)==j,8), length(X), length(a));
         p = reshape(output.roc(output.wrs(:,5)==j,7), length(X), length(a));
         Y(p>0.025 & p<0.975) = 0.5;
         Y(Y<0.5) = Y(Y<0.5)+0.5;
         Yper = [Yper, mean(Y~=0.5,2)*100];
         
%         Y = reshape(output.wrs(output.wrs(:,5)==j,jj), length(X), length(a));
%         Y = reshape(output.anova2(output.anova2(:,5)==j,jj), ...
%             length(X), length(a));
%         Y(Y>0.05) = 1;
%         Y(isnan(Y)) = 1;
%         Yper = [Yper, mean(Y<1,2)*100];
               
        lat = zeros(length(a),1);
        for i = 1:length(a),           
             preLat =  find(((Y(:,i)-0.5)~=0),1);
%             preLat =  nanmin(find(Y(:,i)<1));
            if ~isempty(preLat),
                lat(i) = preLat;
            end
        end
        Y(:,lat==0)=[];
        lat(lat==0) = [];
        [~,minLatID] = sort(lat,'descend');
        sY = Y(:,minLatID);
        figure
%         imagesc(sY');
        imagesc(sY', 'XData', X, 'YData', 1:length(a))
%         imagesc(sY', 'XData', X, 'YData', 1:length(a), [min(min(Y)), 1-min(min(Y))])
%         imagesc(Y', 'XData', X, 'YData', 1:length(a), [min(min(Y)), 1-min(min(Y))])
%         C(33,:) = ones(3,1);
%         C = colormap;
%         C(1,:) = ones(3,1);
%         colormap(C)
        colormap('hot')
        
        colorbar
        ylabel 'Neuron #'
        S = {'Question end','Answer start'};
        xlabel(sprintf('Time aligned to %s (s)',S{j}))
        if jj==7,
%             title 'Thresholded p-value FB vs FO'
%             title 'Thresh p-val Belief'
            title 'Rectified AUROC'
        else
%             title 'Thresholded p-value FB vs TB'
            title 'Thresh p-val Falsehood'
        end
        annotatePlot(anTt);
%     end
end

%%
figure
plot(repmat(X,1,size(Yper,2)), Yper,'linewidth',2)
set(gca,'fontsize',12,'tickdir','out')
xlabel 'Time (s)'
ylabel '% of significant neurons'
box off

if size(Yper,2)==4,
    legend({'Q Belief','Q False','A belief', 'A false'})
else
    legend({'Question','Answer'})
end
annotateFigure(anTt);