function output = tom_testSpikeNames(data, params)
% output = tom_testSpikeNames(data, params)

% Neuronal responses to 'you' vs. 'others'
% params.time         = [500 1000];
% params.inputsize    = 250;
% params.stepsize     = 250;

time = params.time;
inputsize = params.inputsize;
stepsize = params.stepsize;

properNounTime  = data.transcription.Start(data.transcription.properNoun>0 & data.transcription.Sentence==1)*1000;
youTime         = data.transcription.Start(data.transcription.personalNoun==1 & data.transcription.Sentence==1)*1000;

output.rs = [];
theseSlides = (sum(time)-inputsize+stepsize)/stepsize;

% Extract neuronal responses, plot SDF, NHST
for ch = 1:5,
    units = size(data.channel(ch).unit,2);    
    if ~isempty(units),
        for unit = 1:units
            spikeTS = round(data.channel(ch).unit(:,unit).ts*1000); % in ms

            % Obtain bin counts        
            [slidBC_other, slidCtr] = tom_slidingBinCount(spikeTS, ...
                properNounTime, time, inputsize, stepsize);
            
            slidBC_you = tom_slidingBinCount(spikeTS, ...
                youTime, time, inputsize, stepsize);
            
            % plot SDF
            fro = spikeDensity(slidBC_other, params.inputsize);
            fry = spikeDensity(slidBC_you, params.inputsize);
            
            smoothSpk(:,1) = smoothSpikes(fro, 7, 'gauss')';    
            smoothSpk(:,2) = smoothSpikes(fry, 7, 'gauss')';    
            xt = slidCtr./1000;
            figure
            
            plot(repmat(xt(:),1,2), smoothSpk, 'linewidth',2)
            
            top = ceil(max(max(smoothSpk))/10)*10;
            sdfHdl = gca;
            set(sdfHdl,'YLim',[0 top])
            xlabel(sdfHdl,'Time (s) ','fontSize',14)
            ylabel(sdfHdl,'Firing rate (spikes/s)','fontSize',14)
            set(sdfHdl,'tickdir','out','linewidth',0.5,'fontsize',14)
            box off
            legend({'Other','You'});
            name = sprintf('case %d session %d ch %d unit %d',data.case, data.session, ch, unit);
            title(name)
            set(gcf,'name',['tom sdf word start', name])
            
%             pause(.5)
%             export_fig('ToM sdf you_other.pdf', '-append'), 
%             close
                        
            % repeat analyses for each window
            for win = 1:theseSlides
                % simplistic analyses, binary comparison
               try
                 prs = ranksum(slidBC_other(win,:), slidBC_you(win,:));
               catch
                   keyboard
               end
                 identifier = [data.case, data.session, ...
                        ch, unit, slidCtr(win)/1000];
                 output.rs = [output.rs; identifier, prs];
                  
            end            
            
        end
    end
end

% classifier you vs other

% dimensionality reduction

