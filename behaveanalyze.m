% behavioral analysis

clear all;close all;clc;

% read the data 
cd data;
datafiles = matchfiles('*subj97*.mat');
datatmp = cell(1, numel(datafiles));
for i = 1 : numel(datafiles)
    datatmp{i} = load(datafiles{i});
    datatmp{i} = datatmp{i}.sp;
end
cd ..
% We want to compute the reaction time, psychmetric function, utility
% function
%% psychmetric function
% we need the data field, <choiceRecord>, 1=15,2=10'; <prob>
% calculate the expected reward given the money and the probability
choiceRecord = cellfun(@(x) x.choiceRecord, datatmp,'UniformOutput',0);
choiceRecord = cell2mat(choiceRecord);
choiceRecord(choiceRecord==3) = 0; %1,choose green; 0, choose blue;
expectReward_15 = cellfun(@(x) x.prob{1}*15, datatmp,'UniformOutput',0);
expectReward_15 = cell2mat(expectReward_15);
expectReward_10 = cellfun(@(x) x.prob{2}*10, datatmp,'UniformOutput',0);
expectReward_10 = cell2mat(expectReward_10);
expectReward_diff = expectReward_15 - expectReward_10;

close all;
[params, plikeli]=fitpsychometricfun(expectReward_diff, choiceRecord,'cumgauss',struct('chance',0,'thresholdaccu',0.5), 1);
h = gca;
xlabel('EV diff');
%% loss aversion


%% figure out reaction time, maybe not that useful since our choice are delayed


%% end


