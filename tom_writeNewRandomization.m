% tom_writeNewRandomization
session = 'ecog_second'; % {first, second, ecog_first, ecog_second}
sheetName = 'Rand 2 comp 1 ';

% Read Excel file
% readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\prompts list db.xlsx';
readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM ECoG\tom ecog prompts db.xlsx';

[prompts_no, prompts_text, prompts_all] = xlsread(readHere, 'Original');

% Restriction logicals
dtbyou = prompts_no(:,3)<=3 & prompts_no(:,8)==1; % Double-true believe with 'you'
rt = findIndicesInVector(prompts_no(:,1), newOrder(:,1)); % Previously shown...
easy = prompts_no(:,21)==1 | isnan(prompts_no(:,21));
 
% Select and pseudorandomize order of prompts and questions
switch session
    case 'first'
        requested = [   
             0     0     0     0     1     10
             0     1     0     1     0     10
             0     1     1     0     0     10
             1     0     0     1     0     10
             1     0     1     0     0     10];
        newOrder = tom_pseudoRandomization(prompts_no, requested);
        
    case 'second'
        % restrict selection based on previous prompts, assumed to be
        % stored in 'newOrder'
        rt = findIndicesInVector(prompts_no(:,1), newOrder(:,1));
        restrictedPrompts_no = prompts_no(rt==0,:);
        requested = [   
             0     0     0     0     1     7
             0     1     0     1     0     10
             0     1     1     0     0     7
             1     0     0     1     0     7
             1     0     1     0     0     10];
        pre_newOrder = tom_pseudoRandomization(restrictedPrompts_no, requested);

        rt = findIndicesInVector(prompts_no(:,1), pre_newOrder(:,1));
        new_restrictedPrompts_no = prompts_no(rt==0,:);
        requested = [   
             0     0     0     0     1     3     
             0     1     1     0     0     3
             1     0     0     1     0     3];
        pre_newOrder_2 = tom_pseudoRandomization(new_restrictedPrompts_no, requested);

        newOrder = [pre_newOrder; pre_newOrder_2];
    case 'ecog_first'
       
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
                 0     1     1     0     0     0     0  3
                 1     0     0     1     0     0     0  8
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
    rand_prompts(1,[1:8 10:12]) = prompts_text(1,:);
    rand_prompts(1,9) = {'Q Order'};
    for i = 1:size(newOrder,1)    
        rand_prompts(i+1,1:9) = num2cell(newOrder(i,1:9));     
        rand_prompts(i+1,10) = prompts_text(newOrder(i,1)+1,9);
        rand_prompts(i+1,11) = prompts_text(newOrder(i,1)+1,9+newOrder(i,9));
        rand_prompts(i+1,12) = prompts_text(newOrder(i,1)+1,12-newOrder(i,9));
    end
end

% Write to Excel file
xlswrite(readHere, rand_prompts, sheetName, 'A1');
fprintf('Wrote %s. Done!\n',sheetName)