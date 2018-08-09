% behavioral analysis

clear all;close all;clc;

% read the data 
datafiles = matchfiles('*subj96*.mat');
datatmp = cell(1, numel(datafiles));
for i = 1 : numel(datafiles)
    datatmp{i} = load(datafiles{i});
    datatmp{i} = datatmp{i}.sp;
end

% We want to compute the reaction time, psychmetric function, utility
% function


%% psychmetric function
% we need the data field, <choiceRecord>, 1=20,2=5'; <prob>
% calculate the expected reward given the money and the probability
choiceRecord = cellfun(@(x) x.choiceRecord, datatmp,'UniformOutput',0);
choiceRecord = cell2mat(choiceRecord);
choiceRecord(choiceRecord==2) = 0; %1,choose 20; 0, choose 5;
expectReward_20 = cellfun(@(x) x.prob{1}*20, datatmp,'UniformOutput',0);
expectReward_20 = cell2mat(expectReward_20);
expectReward_5 = cellfun(@(x) x.prob{2}*5, datatmp,'UniformOutput',0);
expectReward_5 = cell2mat(expectReward_5);
expectReward_diff = expectReward_20 - expectReward_5;

close all;
[params, plikeli]=fitpsychometricfun(expectReward_diff, choiceRecord,'cumgauss',struct('chance',0,'thresholdaccu',0.5), 1);

%% loss aversion


%% figure out reaction time, maybe not that useful since our choice are delayed




