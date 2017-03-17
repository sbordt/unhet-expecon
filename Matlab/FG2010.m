path = 'C:\Users\sbordt\Dropbox\masterthesis\csv\FG2010\';
files = {'FG2010_All', 'FG2010_CC' , 'FG2010_CC_Distinguishable', 'FG2010_CC_NotConfused', 'FG2010_CC_Distinguishable_NotConfused', 'FG2010_Confused', 'FG2010_Distinguishable', 'FG2010_Distinguishable_NotConfused', 'FG2010_FR', 'FG2010_NotConfused', 'FG2010_TR'};

warning('off');  % matrices are rank deficient ...

for f = 1:length(files)     
    disp(files{f});
    M = csvread(strcat(path,files{f},'.csv'), 1, 0); % load data
    
    y = M(:,3);
    X = M(:,4:5);
    nN = length(M)/10;
    nT = 10;
    nG = 2;                 % 2 groups
    
    lambda_iter = 0.5* var(y) / nT^(1/3); % set the tuning parameter
    
    % carry out PLS estimation for 3 different models
    [b_iter, a_iter, group_iter] = SSP_PLS_est(nN, nT, y, X, nG, lambda_iter, 200);
    [b_iter_belief, a_iter_belief, group_iter_belief] = SSP_PLS_est(nN, nT, y, X(:,1), nG, lambda_iter, 200);
    [b_iter_predcont, a_iter_predcont, group_iter_predcont] = SSP_PLS_est(nN, nT, y, X(:,2), nG, lambda_iter, 200);
    
    disp(a_iter);
    disp(a_iter_belief);
    disp(a_iter_predcont);
    
    % get ID <-> group
    A = M(:,1);
    A_belief = A;
    A_predcont = A;
    
    for i=1:nN
        for j=1:nG
            % full model
            if group_iter(i,j) == 1
                for k=1:nT
                    A(10*(i-1)+k,2) = j;
                end
            end
            
            % belief model
            if group_iter_belief(i,j) == 1
                for k=1:nT
                    A_belief(10*(i-1)+k,2) = j;
                end
            end            
            
            % pred. cont model
            if group_iter_predcont(i,j) == 1
                for k=1:nT
                    A_predcont(10*(i-1)+k,2) = j;
                end
            end
        end
    end

    csvwrite(strcat(path,'PLS\',files{f},'_PLS.csv'), unique(A,'rows'));
    csvwrite(strcat(path,'PLS\',files{f},'_PLS_BeliefOnly.csv'), unique(A_belief,'rows'));
    csvwrite(strcat(path,'PLS\',files{f},'_PLS_PredContOnly.csv'), unique(A_predcont,'rows'));
end