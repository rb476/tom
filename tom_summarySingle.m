% answersTbl = function tom_summarySingle(xls_file, xls_page)
%
% Generate a table summarizing subject answers to diff categories of questions
%
% rbm 2016


% read excel file
[ans_no, ans_text, ans_all] = xlsread(xls_file, xls_page);
% readHere = 'C:\Users\Raymundo\Dropbox\MGH\ToM\ToM\prompts list db PC answers.xlsx';
% [ans_no, ans_text, ans_all] = xlsread(readHere, 'Randomization 3');


% Prepare output table
answersTbl = cell(7,6);
answersTbl(1,:) = {'Cat','Incorrect','Correct','Don''t know','Total','% Correct'};
answersTbl(2:7,1) = {'FB','TB','FO','TO','DTB','Total'};

resp = ans_no(:,[15 17]);

% populate table
for cat = 1:5
    trow = ans_no(:,4+cat);
    arow = ans_no(:,10);
    switch cat
        case {1,2,5}
            % belief questions are always first in the database
            tans = diag(resp(:, arow));
            tans = tans(trow==1);
        otherwise                
            tans = diag(resp(:, 3-arow));
            tans = tans(trow==1);
    end
    locT = zeros(1,3);
    for j = 1:3,
        locT(j) = sum((j-1)==tans);
    end
    answersTbl(cat+1, 2:4) = num2cell(locT);
    answersTbl{cat+1, 5} = sum(locT);
    answersTbl{cat+1, 6} =  100*(locT(2)/sum(locT));
end
% Stat summary
answersTbl(7,2:5) = num2cell(sum(cell2mat(answersTbl(2:6,2:5))));
answersTbl{7,6} = mean([answersTbl{2:6, 6}]);