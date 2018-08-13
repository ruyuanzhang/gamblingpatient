% This is the experiment program for the gambling task on intracranial tasks . This
% project is conducted by Ruyuan Zhang (RZ). Ben Hayden and Ruyuan Zhang conceptualize and
% design the experiment.
%
% History:
%   20180804 RZ created


%% 
clear all; close all; clc;

sp.subj = 95;  % 99,97,RZ; 98, TZ; 96, Roberto;95,
sp.runNo = 3;  % 

addpath(genpath('./utils'));

%% debug purpose
sp.wantFrameFiles = 0; % 1, save all pictures;0, do not save
sp.frameDuration = 6;  % 60 monitor refresh, 15 monitor refreshes per frame, the duration is sp.frameDuration/fresh_rate of the monitor
sp.blank = 4;  % secs, blanck at the begining and the end
%mp = getmonitorparams('uminn7tpsboldscreen');
%mp = getmonitorparams('uminnofficedesk');
mp = getmonitorparams('uminnmacpro');
sp.respKeys = {'1!','2@'};

%% monitor parameter (mp)
%mp = getmonitorparams('uminn7tpsboldscreen');
mp.monitorRect = [0 0 mp.resolution(1) mp.resolution(2)];

%% stimulus parameters (sp)
sp.expName = 'gambling';
sp.nTrials = 64;  % number of trials in a run
sp.moneyOffer = [15, 15, 10, 10]; % reward to 
% we generate two random list for two offers respectively, to compensate
% the situation when two offers are the same color
sp.prob = {rand(1,sp.nTrials), rand(1,sp.nTrials),rand(1,sp.nTrials), rand(1,sp.nTrials)}; 
%sp.posJitter = {rand(1,sp.nTrials), rand(1,sp.nTrials)};  % to gitter position a little bit.
sp.win = {rand(1,sp.nTrials) < sp.prob{1}, rand(1,sp.nTrials) < sp.prob{2}, rand(1,sp.nTrials) < sp.prob{1}, rand(1,sp.nTrials) < sp.prob{1}}; % 1, win, 2, lose
%sp.win = {ones(1,sp.nTrials), ones(1,sp.nTrials)}; % 1, win, 2, lose. For debug purpose, here we assume that subjects all win
sp.winRecord = zeros(1,sp.nTrials);  % record of win and loose in a trial;
sp.choiceRecord = zeros(1,sp.nTrials);  % record of choice for two money offer in a trial;
sp.design = getranddesign(sp.nTrials, [2 4]); % get the sp.design matrix, 1st offer appear (1.left,2.right),4 types of trials (bluegreen/gb/bb/gg)
sp.loc = sp.design(:,2); % 1, 1st appear left;2, 1st offer appear right
sp.whoFirst = sp.design(:,3); % 4 types of trials (bluegreen/gb/bb/gg)
sp.colorIntensity = 200; 
sp.colorList = {[0,sp.colorIntensity, 0], [0,0,sp.colorIntensity]};  % bar colors for g=20 and b=5.
sp.barBgColor = [sp.colorIntensity, 0, 0];
sp.ecc = 6; % deg
sp.barSize = [4.08, 11.35];  % width,height
sp.barLineWidth = 5; % pixels of the bar line Width

sp.stimTime = {[0.5, 0.5],[0.5, 0.5],[0.5, 2]}; %{[A,Agap],[B,Bgap],[feedback,ITI]}
sp.feedbackTime = 1; % secs to show feedback
sp.fixSize = 10; % pixel, size of fixation dot
sp.fixColors = {[255,255,255], [0, 255, 0], [0, 0, 255], [255, 0, 0]}; % white, b, g, r
sp.feedbackBarColor = [255,255,255];
sp.COLOR_GRAY = 127;
sp.COLOR_BLACK = 0;
sp.COLOR_WHITE = 254;


%% calculate more stimulus sizes and rects
sp.eccPix = round(sp.ecc * mp.pixPerDeg(1));  % eccenticity in pixels
sp.barSizePix = round(sp.barSize * mp.pixPerDeg(1));  % bar size in pixels
sp.barRect = [0 0 sp.barSizePix(1) sp.barSizePix(2)]; % bar winRect 
sp.barRectLeft = CenterRect(sp.barRect, mp.monitorRect) + [-sp.eccPix 0 -sp.eccPix 0];   % bar winRect on left of the screen
sp.barRectRight = CenterRect(sp.barRect,mp.monitorRect) + [sp.eccPix 0 sp.eccPix 0];   % bar winRect on left of the screen
sp.feedbackRectLeft = [sp.barRectLeft(1)-sp.barLineWidth, sp.barRectLeft(2)-sp.barLineWidth, sp.barRectLeft(3)+sp.barLineWidth, sp.barRectLeft(4)+sp.barLineWidth];
sp.feedbackRectRight = [sp.barRectRight(1)-sp.barLineWidth, sp.barRectRight(2)-sp.barLineWidth, sp.barRectRight(3)+sp.barLineWidth, sp.barRectRight(4)+sp.barLineWidth];
sp.fixRect = CenterRect([0 0 sp.fixSize, sp.fixSize], mp.monitorRect);
sp.prcentNumPos = {[(sp.barRectLeft(1)+sp.barRectLeft(3))/2-20,(sp.barRectLeft(2)+sp.barRectLeft(4))/2],...
    [(sp.barRectRight(1)+sp.barRectRight(3))/2-20,(sp.barRectRight(2)+sp.barRectRight(4))/2]}; % left/right
%% make the stimulus images
% make blue bar, red
barBlue1 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
barBlue2 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
% fill color of the bar
for i=1:size(barBlue1, 4)
    barBlue1(1:round(sp.barSizePix(2)*sp.prob{1}(i)), :, find(sp.colorList{1}>0), i) = sp.colorIntensity;
    barBlue1(round(sp.barSizePix(2)*sp.prob{1}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
    barBlue2(1:round(sp.barSizePix(2)*sp.prob{2}(i)), :, find(sp.colorList{1}>0), i) = sp.colorIntensity;
    barBlue2(round(sp.barSizePix(2)*sp.prob{2}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
end

% make $5 bar, red
barGreen1 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
barGreen2 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
% fill color of the bar
for i=1:size(barGreen1, 4)
    barGreen1(1:round(sp.barSizePix(2)*sp.prob{3}(i)), :, find(sp.colorList{2}>0), i) = sp.colorIntensity;
    barGreen1(round(sp.barSizePix(2)*sp.prob{3}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
    barGreen2(1:round(sp.barSizePix(2)*sp.prob{4}(i)), :, find(sp.colorList{2}>0), i) = sp.colorIntensity;
    barGreen2(round(sp.barSizePix(2)*sp.prob{4}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
end
sp.barBlue1 = barBlue1;
sp.barBlue2 = barBlue2;
sp.barGreen1 = barGreen1;
sp.barGreen2 = barGreen2;

%% make arguments for ptviewmovie function, saved as into stimulus parameters
% note that modified ptviewmoview.

% Here we define 'frame', which is not the 'frame' in terms of monitor
% refresh sense. It is smallest unit we gonna manipulate screen flip.
%sp.blank = 0;  % secs, blanck at the begining and the end
%sp.frameDuration = 120;  % 120 monitor refresh, that is one second / frame.
sp.stimUnitSecs = sp.frameDuration / mp.refreshRate;  % secs in a frame here
%% MRI related preparation
% some auxillary variables
sp.timeKeys = {};
sp.triggerKey = '5'; % the key to start the experiment
sp.timeFrames=[];
sp.allowedKeys = zeros(1, 256);
sp.allowedKeys([20 41 30:34 89:93 79:80]) = 1;  %20,'q';41,'esc';;30-34, mackeyboard 1-5; 79-80, right/left keys
sp.cumMoney = 0;
sp.updateOrNot = zeros(1, sp.nTrials);  % a marker to show that already update money in this trial, more button press will not update again
getOutEarly = 0;
when = 0;
glitchcnt = 0;
sp.deviceNum = 1; % devicenumber to record input
frameCnt = 0;
%kbQueuecheck setup
KbQueueCreate(1,sp.allowedKeys);

% get information about the PT setup
oldclut = pton([],[],[],1);
win = firstel(Screen('Windows'));
winRect = Screen('Rect',win);
Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
mfi = Screen('GetFlipInterval',win);  % re-use what was found upon initialization!

% text positoin
sp.cumMoneyTxtPos = [winRect(3)-300 , 50];
sp.instrTxtPosWin = [winRect(3)/2-30, winRect(4)/2+50];
sp.instrTxtPosLoose = [winRect(3)/2-40, winRect(4)/2+50];
sp.instrTxtPosPause = [winRect(3)/2-45, winRect(4)/2+50];
sp.instrTxtPosChoose = [winRect(3)/2-80, winRect(4)/2+50];
%% wait for a key press to start, start to show stimulus
Screen('FillRect',win,sp.COLOR_BLACK,winRect);
Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
Screen('TextSize',win,30);Screen('TextFont',win,'Arial');
Screen('DrawText', win, 'Waiting for experiment to start ...',winRect(3)/2-250, winRect(4)/2-50, 127);
Screen('Flip',win);
fprintf('press a key to begin the movie. (make sure to turn off network, energy saver, spotlight, software updates! mirror mode on!)\n');
safemode = 0;
tic;
while 1
  [secs,keyCode,deltaSecs] = KbWait(-3, 2);
  temp = KbName(keyCode);
  if isequal(temp(1),'=')
    if safemode
      safemode = 0;
      fprintf('SAFE MODE OFF (the scan can start now).\n');
    else
      safemode = 1;
      fprintf('SAFE MODE ON (the scan will not start).\n');
    end
  else
    if safemode
    else
      if isempty(sp.triggerKey) || isequal(temp(1),sp.triggerKey)
        break;
      end
    end
  end
end
fprintf('Experiment starts!\n');
Screen('Flip',win);
% issue the trigger and record it
 
%% now run the experiment
% get trigger
KbQueueStart(sp.deviceNum);
tic;
%% present the initial blank period in a run
% just draw the fixation
Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
% draw the money
Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
% present the first frame
%issue the flip command and record the empirical time
[VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
%if we missed, report it
if Missed > 0 & when ~= 0
    glitchcnt = glitchcnt + 1;
    didglitch = 1;
else
    didglitch = 0;
end
% update when to flip next frame, the next frame should be the first frame
% of the first trial
if didglitch
    % if there were glitches, proceed from our earlier when time.
    % set the when time to half a frame before the desired frame.
    % notice that the accuracy of the mfi is strongly assumed here.
    when = (when + mfi / 2) + sp.blank - mfi / 2;
else
    % if there were no glitches, just proceed from the last recorded time
    % and set the when time to half a frame before the desired time.
    % notice that the accuracy of the mfi is only weakly assumed here,
    % since we keep resetting to the empirical VBLTimestamp.
    when = VBLTimestamp + sp.blank - mfi / 2;  % should we be less aggressive??
end
%% now run the real trials
for iTrial = 1:sp.nTrials

    if getOutEarly
        break;
    end
    
    % first figure out the barRect location and who present first 
    barRect1 = choose(sp.loc(iTrial)==1, sp.barRectLeft, sp.barRectRight); % the fist offer appears on the left side
    barRect2 = choose(sp.loc(iTrial)==1, sp.barRectRight, sp.barRectLeft);
    pPrcentPos1 = choose(sp.loc(iTrial)==1, sp.prcentNumPos{1}, sp.prcentNumPos{2});
    pPrcentPos2 = choose(sp.loc(iTrial)==1, sp.prcentNumPos{2}, sp.prcentNumPos{1});
    % figure out who comes first
    switch sp.whoFirst(iTrial)
        case 1 % 1st blue 2nd green
            barTex1 = Screen('MakeTexture',win,sp.barBlue1(:,:,:,iTrial));
            barTex2 = Screen('MakeTexture',win,sp.barGreen1(:,:,:,iTrial));
            pPrcnt = [sp.prob{1}(iTrial),sp.prob{3}(iTrial)];
        case 2 % 1st green 2nd blue
            barTex1 = Screen('MakeTexture',win,sp.barGreen1(:,:,:,iTrial));
            barTex2 = Screen('MakeTexture',win,sp.barBlue1(:,:,:,iTrial));
            pPrcnt = [sp.prob{3}(iTrial),sp.prob{1}(iTrial)];
        case 3 % 1st blue 2nd blue
            barTex1 = Screen('MakeTexture',win,sp.barBlue1(:,:,:,iTrial));
            barTex2 = Screen('MakeTexture',win,sp.barBlue2(:,:,:,iTrial));
            pPrcnt = [sp.prob{1}(iTrial),sp.prob{2}(iTrial)];
        case 4 % 1st green 2nd green
            barTex1 = Screen('MakeTexture',win,sp.barGreen1(:,:,:,iTrial));
            barTex2 = Screen('MakeTexture',win,sp.barGreen2(:,:,:,iTrial));
            pPrcnt = [sp.prob{3}(iTrial),sp.prob{4}(iTrial)];
    end
    
    %% present offer A
    % draw texture
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawTexture', win, barTex1, [], barRect1);
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(1)*100)),pPrcentPos1(1), pPrcentPos1(2), 255);
    %if when == 0 || GetSecs >= when
        %issue the flip command and record the empirical time
        [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
        if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
        sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
        %if we missed, report it
        if Missed > 0 & when ~= 0
            glitchcnt = glitchcnt + 1;
            didglitch = 1;
        else
            didglitch = 0;
        end
    %end
    % update when to flip next frame
    if didglitch
        when = (when + mfi / 2) + sp.stimTime{1}(1) - mfi / 2; % sp.stimTime{1}(1) is the time for 1st offer
    else
        when = VBLTimestamp + sp.stimTime{1}(1) - mfi / 2;  % should we be less aggressive??
    end
    
    
    %% gap after A
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    Screen('DrawText', win, 'Pause...', sp.instrTxtPosPause(1), sp.instrTxtPosPause(2), 127);
    %issue the flip command and record the empirical time
    [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
    if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
    sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
    %if we missed, report it
    if Missed > 0 & when ~= 0
        glitchcnt = glitchcnt + 1;
        didglitch = 1;
    else
        didglitch = 0;
    end
    % update when to flip next frame
    if didglitch
        when = (when + mfi / 2) + sp.stimTime{1}(2) - mfi / 2; % sp.stimTime{1}(2) is the time the gap after 1st offer
    else
        when = VBLTimestamp + sp.stimTime{1}(2) - mfi / 2;  % should we be less aggressive??
    end
    
    %% present offer B
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawTexture', win, barTex2, [], barRect2);
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(2)*100)),pPrcentPos2(1), pPrcentPos2(2), 255);
    %issue the flip command and record the empirical time
    [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
    if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
    sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
    %if we missed, report it
    if Missed > 0 & when ~= 0
        glitchcnt = glitchcnt + 1;
        didglitch = 1;
    else
        didglitch = 0;
    end
    % update when to flip next frame
    if didglitch
        when = (when + mfi / 2) + sp.stimTime{2}(1) - mfi / 2; % sp.stimTime{2}(1) is the time for 2nd offer
    else
        when = VBLTimestamp + sp.stimTime{2}(1) - mfi / 2;  % should we be less aggressive??
    end
    %% gap after B
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    Screen('DrawText', win, 'Pause...', sp.instrTxtPosPause(1), sp.instrTxtPosPause(2), 127);
    %issue the flip command and record the empirical time
    [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
    if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
    sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
    %if we missed, report it
    if Missed > 0 & when ~= 0
        glitchcnt = glitchcnt + 1;
        didglitch = 1;
    else
        didglitch = 0;
    end
    % update when to flip next frame
    if didglitch
        when = (when + mfi / 2) + sp.stimTime{2}(2) - mfi / 2; % sp.stimTime{1}(2) is the time the gap after 2nd offer
    else
        when = VBLTimestamp + sp.stimTime{2}(2) - mfi / 2;  % should we be less aggressive??
    end
    %% present both choice and detect key board choice
    % we write a loop since we have to detect keyboard
    % flip and show the stimulus
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);   
    Screen('DrawTexture', win, barTex1, [], barRect1);
    Screen('DrawTexture', win, barTex2, [], barRect2);
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(1)*100)),pPrcentPos1(1), pPrcentPos1(2), 255);
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(2)*100)),pPrcentPos2(1), pPrcentPos2(2), 255);
    Screen('DrawText', win, 'Please choose', sp.instrTxtPosChoose(1), sp.instrTxtPosChoose(2), 127);
    
    %issue the flip command and record the empirical time
    [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
    if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
    sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
    %if we missed, report it
    if Missed > 0 & when ~= 0
        glitchcnt = glitchcnt + 1;
        didglitch = 1;
    else
        didglitch = 0;
    end
    % Note that here we do not choose
%     % update when to flip next frame
%     if didglitch
%         when = (when + mfi / 2) + sp.stimTime{3}(1) - mfi / 2; % sp.stimTime{3}(1) is the time for the 3rd choice
%     else
%         when = VBLTimestamp + sp.stimTime{3}(1) - mfi / 2;  % should we be less aggressive??
%     end
    % detect the response
    while 1
        %detect responses
        [keyIsDown,secs] = KbQueueCheck(sp.deviceNum);  % all devices, only check 'q','esc','1'-'5'
        if keyIsDown
            %get the name of the key and record it
            kn = KbName(secs);
            if iscell(kn); kn = kn{end};end
            sp.timeKeys = [sp.timeKeys; {secs(find(secs)) kn}];
            %check if ESCAPE was pressed
            if isequal(kn,'ESCAPE')
                fprintf('Escape key detected.  Exiting prematurely.\n');
                getOutEarly = 1;
                break;
            end
            when = secs(find(secs)); % when to flip the next, feedback image
            break;
        end
    end
    %% give feedback
    % update reward based on the choice
    if kn == sp.respKeys{1}  % choose left
        switch sp.whoFirst(iTrial)
            case 1 %1st, blue, 2nd,green
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==1,1,3);
            case 2 %1st, green, 2nd,blue
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==1,3,1);
            case 3 %1st, blue;2nd, blue
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==1,1,2);
            case 4 %1st, green;2nd, green
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==1,3,4);
        end
        feedbackRect = sp.feedbackRectLeft;
    elseif kn == sp.respKeys{2}  % choose right
        switch sp.whoFirst(iTrial)
            case 1 %1st, blue, 2nd,green
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==2,1,3);
            case 2 %1st, green, 2nd,blue
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==2,3,1);
            case 3 %1st, blue;2nd, blue
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==2,1,2);
            case 4 %1st, green;2nd, green
                sp.choiceRecord(iTrial) = choose(sp.loc(iTrial)==2,3,4);
        end
        feedbackRect = sp.feedbackRectRight;
    end
    sp.winRecord(iTrial) = sp.win{sp.choiceRecord(iTrial)}(iTrial); % 1, win; 0,loose
    feedbackText = choose(sp.winRecord(iTrial)==1, 'Win!', 'Loose!');
    feedbackTextPos = choose(sp.winRecord(iTrial)==1, sp.instrTxtPosWin, sp.instrTxtPosLoose);
    sp.cumMoney = sp.cumMoney + sp.moneyOffer(sp.choiceRecord(iTrial)) * sp.winRecord(iTrial);
    
    % present feedback
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    Screen('FillRect', win, sp.feedbackBarColor, feedbackRect); % draw feedback rect
    Screen('DrawTexture', win, barTex1, [], barRect1);
    Screen('DrawTexture', win, barTex2, [], barRect2);
    Screen('DrawTexture', win, barTex2, [], barRect2); % draw feedback rect
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(1)*100)),pPrcentPos1(1), pPrcentPos1(2), 255);
    Screen('DrawText', win, sprintf('%2.0f%%', floor(pPrcnt(2)*100)),pPrcentPos2(1), pPrcentPos2(2), 255);
    Screen('DrawText', win, feedbackText,feedbackTextPos(1), feedbackTextPos(2), 127);
    
    if when == 0 || GetSecs >= when
        %issue the flip command and record the empirical time
        [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
        if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
        sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
        %if we missed, report it
        if Missed > 0 & when ~= 0
            glitchcnt = glitchcnt + 1;
            didglitch = 1;
        else
            didglitch = 0;
        end
    end
    % update when to flip next frame
    when = VBLTimestamp + sp.feedbackTime - mfi / 2;  % should we be less aggressive??
    
    %% inter-trial interval
    Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
    Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
    %issue the flip command and record the empirical time
    [VBLTimestamp,~,~,Missed,~] = Screen('Flip',win, when);
    if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
    sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
    %if we missed, report it
    if Missed > 0 & when ~= 0
        glitchcnt = glitchcnt + 1;
        didglitch = 1;
    else
        didglitch = 0;
    end
    % update when to flip next frame
    if didglitch
        when = (when + mfi / 2) + sp.stimTime{3}(2) - mfi / 2; % sp.stimTime{3}(2) is the time the intertrial gap
    else
        when = VBLTimestamp + sp.stimTime{3}(2) - mfi / 2;  % should we be less aggressive??
    end
end
%% present post blank
% just draw the fixation
Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
Screen('DrawText', win, sprintf('Total won: $%d', sp.cumMoney),sp.cumMoneyTxtPos(1), sp.cumMoneyTxtPos(2), 127);
[VBLTimestamp,StimulusOnsetTime,FlipTimestamp,Missed,Beampos] = Screen('Flip',win, when);
if sp.wantFrameFiles;imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));frameCnt=frameCnt+1;end    % write to file if desired
sp.timeFrames = [sp.timeFrames, VBLTimestamp]; %  record the flip time of every frame
%if we missed, report it
if Missed > 0 & when ~= 0
    glitchcnt = glitchcnt + 1;
    didglitch = 1;
else
    didglitch = 0;
end
% update when to flip next frame, the next frame should be the first frame
% of the first trial
if didglitch
    when = (when + mfi / 2) + sp.blank - mfi / 2;
else
    when = VBLTimestamp + sp.blank - mfi / 2;  % should we be less aggressive??
end
%%
toc
ptoff(oldclut);
%% clean up and save data
rmpath(genpath('./utils'));  % remove the utils path
c = fix(clock);
filename=sprintf('%d%02d%02d%02d%02d%02d_exp%s_subj%02d_run%02d',c(1),c(2),c(3),c(4),c(5),c(6),sp.expName,sp.subj,sp.runNo);
save(filename); % save everything to the file;
