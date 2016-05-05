% tom_writeNewRandomization

% Read Excel file
readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM\ToM\prompts list db.xlsx';
[prompts_no, prompts_text, prompts_all] = xlsread(readHere, 'Original');

% Select and pseudorandomize order of prompts and questions
newOrder = tom_pseudoRandomization(prompts_no);

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
xlswrite(readHere, rand_prompts, 'Randomization 9', 'A1')