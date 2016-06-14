% tom_writeNewRandomization
session = 'second'; % {first, second}
sheetName = 'Randomization X';

% Read Excel file
readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM (Shared)\ToM\prompts list db.xlsx';
[prompts_no, prompts_text, prompts_all] = xlsread(readHere, 'Original');

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
end

% Create 'cell' that will be written to Excel
clear rand_prompts
rand_prompts(1,[1:8 10:12]) = prompts_text(1,:);
rand_prompts(1,9) = {'Q Order'};
for i = 1:size(newOrder,1)    
    rand_prompts(i+1,1:9) = num2cell(newOrder(i,1:9));     
    rand_prompts(i+1,10) = prompts_text(newOrder(i,1)+1,9);
    rand_prompts(i+1,11) = prompts_text(newOrder(i,1)+1,9+newOrder(i,9));
    rand_prompts(i+1,12) = prompts_text(newOrder(i,1)+1,12-newOrder(i,9));
end

% Write to Excel file
xlswrite(readHere, rand_prompts, sheetName, 'A1');
fprintf('Wrote %s. Done!\n',sheetName)