% tom_writeNewRandomization
session = 'ecog_second'; % {first, second, ecog_first, ecog_second}
sheetName = 'Randomization 4';

% Read Excel file
% readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\prompts list db - corrected 2.xlsx';
% readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\prompts list db characterized.xlsx';
readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM ECoG\tom ecog prompts db.xlsx';

[prompts_no, prompts_text, prompts_all] = xlsread(readHere, 'Original');
prompts = readtable(readHere,'Sheet','Original');
prompts(isnan(prompts.ID_no),:) = []; % remove NaN rows

% Restriction logicals
dtbyou = prompts.branch_no<=3 & prompts.dbl_true_believe==1; % Double-true believe with 'you' (ECOG)
easy = prompts.easy_question==1 | isnan(prompts.easy_question); % either ea
if exist('newOrder','var')
    rt = findIndicesInVector(prompts.ID_no, newOrder(:,1)); % Previously shown...
end
 
% Select and pseudorandomize order of prompts and questions
switch session
    case 'first'
        restrictedPrompts_no = prompts_no(easy,:);
        requested = [   
                     0     0     0     1     1     5
                     0     0     1     0     1     5
                     0     1     0     1     0     10
                     0     1     1     0     0     10
                     1     0     0     1     0     10
                     1     0     1     0     0     10];
        newOrder = tom_pseudoRandomization(restrictedPrompts_no, requested);
        
    case 'second'
        % restrict selection based on previous prompts, assumed to be
        % stored in 'newOrder'
        
        % Get prompts that weren't in the first batch and are easy
        rt = findIndicesInVector(prompts_no(:,1), newOrder(:,1));
        restrictedPrompts_no = prompts_no(rt==0 & easy,:); 
       requested = [   
                     0     0     0     1     1     4                     
                     0     1     0     1     0     5
                     0     1     1     0     0     2                     
                     1     0     1     0     0     8];
        pre_newOrder = tom_pseudoRandomization(restrictedPrompts_no, requested);
        
        % get prompts from the first batch to complement
        rt = findIndicesInVector(prompts_no(:,1), pre_newOrder(:,1));
        new_restrictedPrompts_no = prompts_no(rt==0,:);
        requested = [   
                     0     0     0     1     1     1
                     0     0     1     0     1     5
                     0     1     0     1     0     5
                     0     1     1     0     0     8
                     1     0     0     1     0     10
                     1     0     1     0     0     2];
        pre_newOrder_2 = tom_pseudoRandomization(new_restrictedPrompts_no, requested);

        newOrder = [pre_newOrder; pre_newOrder_2];
    case 'ecog_first'
       % inference, dfb & 
        restrictedPrompts_no  = prompts_no(dtbyou==0 & easy,:); % ignore DTB with 'you'
        requested = [
                 0     0     0     0     0     0     1  6
                 0     0     0     1     0     1     0  6    
                 0     0     0     1     1     0     0  6                  
                 0     1     0     1     0     0     0  6
                 0     1     1     0     0     0     0  6
                 1     0     0     1     0     0     0  6
                 1     0     1     0     0     0     0  6];
         newOrder = tom_pseudoRandomization(restrictedPrompts_no, requested);
         
     case 'ecog_second'
        % restrict selection based on previous prompts, assumed to be
        % stored in 'newOrder'
       
        restrictedPrompts_no = prompts_no(dtbyou==0 & rt==0 & easy,:); % ignore previous prompts
        
        requested = [
                 0     0     0     0     0     0     1  8
                 0     0     0     1     0     1     0  8    
                 0     0     0     1     1     0     0  8
                 0     1     0     1     0     0     0  8
                 0     1     1     0     0     0     0  5
                 1     0     0     1     0     0     0  4
                 1     0     1     0     0     0     0  8];
             
         newOrder = tom_pseudoRandomization(restrictedPrompts_no, requested);
end

%% Create 'cell' that will be written to Excel
clear rand_prompts
if strfind(session,'ecog') 
    % with inference
    rand_prompts(1,[1:10 12:14]) = prompts_text(1,[1:10, 22:24]);
    rand_prompts(1,11) = {'Q Order'};
    for i = 1:size(newOrder,1)    
        rand_prompts(i+1,1:11) = num2cell(newOrder(i,[1:10 end]));     
        rand_prompts(i+1,12) = prompts_text(newOrder(i,1)+1,22);
        rand_prompts(i+1,13) = prompts_text(newOrder(i,1)+1,22+newOrder(i,22));
        rand_prompts(i+1,14) = prompts_text(newOrder(i,1)+1,25-newOrder(i,22));
    end
else
    % Without inference
    rand_prompts(1,[1:8 10:12]) = prompts_text(1,[1:8 20:22]);
    rand_prompts(1,9) = {'Q Order'};
    for i = 1:size(newOrder,1)    
        rand_prompts(i+1,1:9) = num2cell(newOrder(i,[1:8 20]));     
        rand_prompts(i+1,10) = prompts_text(newOrder(i,1)+1,20); %  +1 to account for header row
        rand_prompts(i+1,11) = prompts_text(newOrder(i,1)+1,20+newOrder(i,20)); % rearrange questions based on question order
        rand_prompts(i+1,12) = prompts_text(newOrder(i,1)+1,23-newOrder(i,20));
    end
end

% Write to Excel file
xlswrite(readHere, rand_prompts, sheetName, 'A1');
fprintf('Wrote %s. Done!\n',sheetName)