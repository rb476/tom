% Use this script to append to all sessions indicator functions (labels)
% related to words, e.g. proper nouns, possesive pronouns, nominative
% pronouns, etc.

% %%
% allWords = [];
% for i = 1:length(allCases),
%     if ~isempty(allCases(i))
%         for ii = 1:size(allCases(i).session,2),
%            localWords = allCases(i).session(ii).transcription.Words;
%            allWords = [allWords; localWords];
%         end
%     end
% end
% uW = unique(lower(allWords));

%% Manual work %%%
% mark every proper noun (person name) with 1 and possesive proper nouns
% (person name with apostrophe) with 2 in the second column of uW
%% 
for i = 1:size(uW,1),
    if isempty(uW{i,2}), 
        uW{i,2} = 0;        
    end
end
properNoun = uW([uW{:,2}]>0,1);
possesivePronouns = {'my', 'mine', 'its', 'his', 'her', 'hers', 'their', 'theirs'};
nominativePronouns = {'she', 'he', 'we', 'they','who'};

for i = 1:length(allCases),
    if ~isempty(allCases(i))
        for ii = 1:size(allCases(i).session,2),
           localWords = lower(allCases(i).session(ii).transcription.Words);
           llw = length(localWords);
           wordIsproperNoun = zeros(llw,1);
           wordIsPronoun = zeros(llw,1);
           for iii = 1:llw
               wordIsproperNoun(iii) = sum(strcmp(localWords(iii), properNoun));
               
               if strcmpi(localWords(iii),'you')
                    wordIsPronoun(iii) = 1;
               elseif sum(strcmpi(localWords(iii), nominativePronouns))
                    wordIsPronoun(iii) = 2;
               elseif sum(strcmpi(localWords(iii), possesivePronouns))
                    wordIsPronoun(iii) = 3;
               end
           end
           allCases(i).session(ii).transcription.properNoun = wordIsproperNoun;
           allCases(i).session(ii).transcription.personalNoun = wordIsPronoun;
        end
    end
end
save('ToM_allCases','allCases')