% This is the experiment program for gambling task on human brain. This
% project is conducted by Ruyuan Zhang (RZ). Ben Hayden and Ruyuan Zhang conceptualize and
% design the experiment.
%
% This is the longer version of the gambling task. We decide 
%
% The basic trial structure is A(2s),Agap = [9 10 11 12 13], B(2s), Bgap
% [2,3,4], c(motror)2s, Cgap = [4 5 6 7 8].
%
% History:
%   20180625 RZ polished this
%   20180513 RZ created it.


%% 
clear all; close all; clc;

%sp.subj = input('Input the subj number: \n');
%sp.runNo = input('Input the run number: \n');

sp.subj = 95;  % 99,97,RZ; 98, TZ; 96, Roberto;95,
sp.runNo = 3;  % 

addpath(genpath('./utils'));

%% debug purpose
sp.wantFrameFiles = 0; % 1, save all pictures;0, do not save
sp.frameDuration = 15;  % 60 monitor refresh, 15 monitor refreshes
sp.blank = 8;  % secs, blanck at the begining and the end
%mp = getmonitorparams('uminn7tpsboldscreen');
%mp = getmonitorparams('uminnofficedesk');
mp = getmonitorparams('uminnmacpro');
sp.respKeys = {'1!','2@'};

%% monitor parameter (mp)
%mp = getmonitorparams('uminn7tpsboldscreen');
mp.monitorRect = [0 0 mp.resolution(1) mp.resolution(2)];

%% stimulus parameters (sp)
sp.expName = 'gambling';
sp.nTrials = 12;  % number of trials in a session
sp.moneyOffer = [10, 5];
sp.prob = {rand(1,sp.nTrials), rand(1,sp.nTrials)};  % randomize probility for two offers
sp.posJitter = {rand(1,sp.nTrials), rand(1,sp.nTrials)};  % to gitter position a little bit.
sp.win = {rand(1,sp.nTrials) < sp.prob{1}, rand(1,sp.nTrials) < sp.prob{2}}; % 1, win, 2, lose
%sp.win = {ones(1,sp.nTrials), ones(1,sp.nTrials)}; % 1, win, 2, lose. For debug purpose, here we assume that subjects all win
sp.winRecord = zeros(1,sp.nTrials);  % record of win and loose in a trial;
sp.choiceRecord = zeros(1,sp.nTrials);  % record of choice (20 or 5) in a trial;
design = getranddesign(sp.nTrials, [2 2]);
sp.loc = design(:,2); % 1, 20 dollar offer on the left;2, 20 dollor offer on the right. 
sp.whoFirst = design(:,3); % 1, 20 dollar offer first; 2, 5 dollor offer first. 
sp.colorIntensity = 200; 
sp.colorList = {[0,sp.colorIntensity, 0], [0,0,sp.colorIntensity]};  % bar colors for g=20 and b=5.
sp.barBgColor = [sp.colorIntensity, 0, 0];
sp.ecc = 6; % deg
sp.barSize = [4.08, 11.35];  % width,height
sp.barLineWidth = 5; % pixels of the bar line Width
sp.stimTime = {[2,2],[2,2],[2,4]}; % secs, timing for three phases; [A,B], A is the stimulus onset time; B is blank
sp.fixSize = 10; % pixel, size of fixation dot
sp.fixColors = {[255,255,255], [0, 255, 0], [0, 0, 255], [255, 0, 0]}; % white, b, g, r
sp.COLOR_GRAY = 127;
sp.COLOR_BLACK = 0;
sp.COLOR_WHITE = 254;

%% calculate more stimulus sizes and rects
sp.eccPix = round(sp.ecc * mp.pixPerDeg(1));  % eccenticity in pixels
sp.barSizePix = round(sp.barSize * mp.pixPerDeg(1));  % bar size in pixels
sp.barRect = [0 0 sp.barSizePix(1) sp.barSizePix(2)]; % bar winRect 
sp.barRectLeft = CenterRect(sp.barRect, mp.monitorRect) + [-sp.eccPix 0 -sp.eccPix 0];   % bar winRect on left of the screen
sp.barRectRight = CenterRect(sp.barRect,mp.monitorRect) + [sp.eccPix 0 sp.eccPix 0];   % bar winRect on left of the screen
sp.fixRect = CenterRect([0 0 sp.fixSize, sp.fixSize], mp.monitorRect);

%% make the stimulus images
% make $20 bar, red
bar20 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
%bar20(:, :, find(sp.barbgcolor>0), :) = sp.colorIntensity;  % set the background color
%bar20(1:sp.barlinewidth, :, find(sp.colorList{1}>0), :) = sp.colorIntensity;  % add border lines
%bar20(:, 1:sp.barlinewidth, find(sp.colorList{1}>0), :) = sp.colorIntensity;
%bar20(end - sp.barlinewidth:end, :, find(sp.colorList{1}>0), :) = sp.colorIntensity;
%bar20(:, end - sp.barlinewidth:end, find(sp.colorList{1}>0), :) = sp.colorIntensity;
% fill color of the bar
for i=1:size(bar20, 4)
    bar20(1:round(sp.barSizePix(2)*sp.prob{1}(i)), :, find(sp.colorList{1}>0), i) = sp.colorIntensity;
    bar20(round(sp.barSizePix(2)*sp.prob{1}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
end

% make $5 bar, red
bar05 = zeros([sp.barSizePix(2) sp.barSizePix(1) 3 sp.nTrials]);
% fill color of the bar
for i=1:size(bar05, 4)
    bar05(1:round(sp.barSizePix(2)*sp.prob{2}(i)), :, find(sp.colorList{2}>0), i) = sp.colorIntensity;
    bar05(round(sp.barSizePix(2)*sp.prob{2}(i))+1:end, :, find(sp.barBgColor>0), i) = sp.colorIntensity;
end
sp.bar20 = bar20;
sp.bar05 = bar05;

%% make arguments for ptviewmovie function, saved as into stimulus parameters
% note that modified ptviewmoview.

% Here we define 'frame', which is not the 'frame' in terms of monitor
% refresh sense. It is smallest unit we gonna manipulate screen flip.
%sp.blank = 0;  % secs, blanck at the begining and the end
%sp.frameDuration = 120;  % 120 monitor refresh, that is one second / frame.
sp.stimUnitSecs = sp.frameDuration / mp.refreshRate;  % secs in a frame here

% now we compute the frameorderintrial, this part is difficult to understand
% from a reader's point of view, try to explain it more clear
sp.nframesPerSecs = mp.refreshRate / sp.frameDuration; % how many image frames in a secs. Note that this is not monitor refresh rate
sp.trialEvents = [1,0,2,0,3,0];  % just give a label to individual events in a trial. Here, 1:show offer 1;2, show offer2;3, show both offer;0, is blank.
sp.AList = Shuffle(2*ones(1, sp.nTrials)); % time for A offer is always 2 secs
[sp.AgapList, idx] = Shuffle([9 11 12 12 13 14 9 11 12 12 13 14]); % Agap on average is 12 seconds
%[sp.AgapList, idx] = Shuffle([2 2 2 2 2 2 2 2 2 2 2 2]); % Agap on average is 12 seconds
sp.BList = sp.AList; % time for B offer is always 2 secs
sp.BgapList = [2 3 4 2 3 4 2 3 4 2 3 4]; % Bgap on average 3 seconds
sp.BgapList = sp.BgapList(idx);
sp.CList = sp.BList; % note that we do not show both offers now.
sp.CgapList = [8 7 6 6 5 4 8 7 6 6 5 4]; % cgap on average 6 seconds
%sp.CgapList = [3 3 3 3 3 3 3 3 3 3 3 3]; % cgap on average 6 seconds
sp.CgapList = sp.CgapList(idx);

sp.frameOrder = [];
sp.trialIdx = [];
sp.checkWinIdxOrNot = [];
for iTrial = 1:sp.nTrials
    temp =[repmat(1*ones(1,sp.nframesPerSecs), 1, sp.AList(iTrial)) ...    % offer A
        repmat(zeros(1,sp.nframesPerSecs), 1, sp.AgapList(iTrial)) ...  % Agap
        repmat(2*ones(1,sp.nframesPerSecs), 1, sp.BList(iTrial)) ...    % offer B
        repmat(zeros(1,sp.nframesPerSecs), 1, sp.BgapList(iTrial)) ...  % Bgap
        repmat(3*ones(1,sp.nframesPerSecs), 1, sp.CList(iTrial)) ...    % offer C
        repmat(zeros(1,sp.nframesPerSecs), 1, sp.CgapList(iTrial))];    % Cgap
    sp.frameOrder = [sp.frameOrder temp];
    sp.trialIdx = [sp.trialIdx iTrial*ones(1, length(temp))]; % the trial index of each presentation frame
    
    % compute the idx flag when to check button press, This stage include
    % offer C + Cgap
    temp2 = [repmat(zeros(1,sp.nframesPerSecs), 1, sp.AList(iTrial) + sp.AgapList(iTrial) + sp.BList(iTrial) + sp.BgapList(iTrial)) ...
        repmat(ones(1,sp.nframesPerSecs), 1, sp.CList(iTrial) + sp.CgapList(iTrial))];
    sp.checkWinIdxOrNot = [sp.checkWinIdxOrNot temp2]; 
end
sp.totalTime = length(sp.frameOrder)/sp.nframesPerSecs + sp.blank * 2;  % secs
% add the 16 blank at the beginning and the end
tmp = zeros(1, sp.nframesPerSecs * sp.blank);
sp.frameOrder = [tmp sp.frameOrder tmp];
sp.trialIdx = [tmp sp.trialIdx tmp];
sp.checkWinIdxOrNot = [tmp sp.checkWinIdxOrNot tmp];
%% MRI related preparation
% some auxillary variables
sp.timeKeys = {};
sp.triggerKey = '5'; % the key to start the experiment
sp.timeFrames=zeros(1, length(sp.frameOrder));
sp.allowedKeys = zeros(1, 256);
sp.allowedKeys([20 41 30:34 89:93 79:80]) = 1;  %20,'q';41,'esc';89-93,'1'-'5';30-34, mackeyboard 1-5; 79-80, right/left keys
sp.cumMoney = 0;
sp.updateOrNot = zeros(1, sp.nTrials);  % a marker to show that already update money in this trial, more button press will not update again
getOutEarly = 0;
when = 0;
glitchcnt = 0;
sp.deviceNum = 1; % devicenumber to record input
%kbQueuecheck setup
KbQueueCreate(1,sp.allowedKeys);

% get information about the PT setup
oldclut = pton([],[],[],1);
win = firstel(Screen('Windows'));
winRect = Screen('Rect',win);
Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
mfi = Screen('GetFlipInterval',win);  % re-use what was found upon initialization!

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
fprintf('Experiment starts!')
Screen('Flip',win);
% issue the trigger and record it
 
%% now run the experiment
% get trigger
KbQueueStart(sp.deviceNum);
tic;
for frameCnt = 1:length(sp.frameOrder)

    if getOutEarly
        break;
    end
    
    % figure the drawing type
    if sp.frameOrder(frameCnt) == 0  % blank image, in this case only draw a fixation point
        if sp.checkWinIdxOrNot(frameCnt) == 1 & ~sp.updateOrNot(sp.trialIdx(frameCnt))  % in two offer phase, but not update the money (not respond yet)
            Screen('FillOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  % 
        elseif sp.checkWinIdxOrNot(frameCnt) == 1 & sp.updateOrNot(sp.trialIdx(frameCnt))  % already update response
            if  sp.winRecord(sp.trialIdx(frameCnt)) == 1
                Screen('FillOval', win, sp.fixColors{sp.choiceRecord(sp.trialIdx(frameCnt)) + 1}, CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  % subject win in this trial give feedback
            else
                Screen('FillOval', win, sp.fixColors{4},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  % subject lose in this trial give feedback
            end
        else % in the blank Agap or Bgap, just provide a normal fixtion
            Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
        end
        Screen('DrawText', win, sprintf('$%d', sp.cumMoney),winRect(3)/2-25, winRect(4)/2+50, 127);
    else
        % figure out the winRect location and who comes first
        barRect1 = choose(sp.loc(sp.trialIdx(frameCnt))==1, sp.barRectLeft, sp.barRectRight);
        barRect2 = choose(sp.loc(sp.trialIdx(frameCnt))==1, sp.barRectRight, sp.barRectLeft);
        if sp.whoFirst(sp.trialIdx(frameCnt)) == 1  % 20 dollor offer first
            barTex1 = Screen('MakeTexture',win,sp.bar20(:,:,:,sp.trialIdx(frameCnt)));
            barTex2 = Screen('MakeTexture',win,sp.bar05(:,:,:,sp.trialIdx(frameCnt)));
        elseif sp.whoFirst(sp.trialIdx(frameCnt)) == 2 % 5 dollor offer first
            barTex1 = Screen('MakeTexture',win,sp.bar20(:,:,:,sp.trialIdx(frameCnt)));
            barTex2 = Screen('MakeTexture',win,sp.bar05(:,:,:,sp.trialIdx(frameCnt)));
        end
        
        % draw the texture
        if sp.frameOrder(frameCnt) == 1  % show first offer
            Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
            Screen('DrawTexture', win, barTex1, [], barRect1);
            Screen('DrawText', win, sprintf('$%d', sp.cumMoney),winRect(3)/2-25, winRect(4)/2+50, 127);
        elseif sp.frameOrder(frameCnt) == 2  % show second offer
            Screen('FrameOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));
            Screen('DrawTexture', win, barTex2, [], barRect2);
            Screen('DrawText', win, sprintf('$%d', sp.cumMoney),winRect(3)/2-25, winRect(4)/2+50, 127);
        elseif sp.frameOrder(frameCnt) == 3  % Note that in this stage we do not show both offers, only show fixation
            if sp.updateOrNot(sp.trialIdx(frameCnt)) % check whether we update the offer
                if  sp.winRecord(sp.trialIdx(frameCnt)) % subject win
                    Screen('FillOval', win, sp.fixColors{sp.choiceRecord(sp.trialIdx(frameCnt)) + 1}, CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  % subject win and choose blue
                else % subject lose
                    Screen('FillOval', win, sp.fixColors{4},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  % subject lose in this trial give feedback
                end
            else % have not update yet, just give a normal fixation
                Screen('FillOval', win, sp.fixColors{1},CenterRect([0 0 sp.fixSize sp.fixSize], winRect));  
            end
            %Screen('DrawTexture', win, barTex1, [], barRect1);
            %Screen('DrawTexture', win, barTex2, [], barRect2);
            Screen('DrawText', win, sprintf('$%d', sp.cumMoney),winRect(3)/2-25, winRect(4)/2+50, 127);
        end        
    end
    
    % detect button press
    kn = '';
    while 1
        % if we are in the initial case OR if we have hit the when time, then display the frame
        if when == 0 || GetSecs >= when
            % issue the flip command and record the empirical time
            [VBLTimestamp,StimulusOnsetTime,FlipTimestamp,Missed,Beampos] = Screen('Flip',win, when);
            %      sound(sin(1:2000),100);
            sp.timeFrames(frameCnt) = VBLTimestamp;
            
            % if we missed, report it
            if Missed > 0 & when ~= 0
                glitchcnt = glitchcnt + 1;
                didglitch = 1;
            else
                didglitch = 0;
            end
            % get out of this loop
            break;
            
            % otherwise, try to read input
        else
            [keyIsDown,secs] = KbQueueCheck(sp.deviceNum);  % all devices, only check 'q','esc','1'-'5'
            if keyIsDown
                % get the name of the key and record it
                kn = KbName(secs);
                sp.timeKeys = [sp.timeKeys; {secs(find(secs)) kn}];
                % check if ESCAPE was pressed
                if isequal(kn,'ESCAPE')
                    fprintf('Escape key detected.  Exiting prematurely.\n');
                    getOutEarly = 1;
                    break;
                end
                
            end
          
        end
        
    end
    
    % update win and money
    % we update money, if: 
    % (1) in two-offer stage, sp.checkWinIdxOrNot(frameCnt) = 1
    % (2) no update in this trial, ~sp.updateOrNot(sp.trialIdx(frameCnt))
    % (3) subject press the two designed buttons (no update if the subject presses other buttons)
    if sp.checkWinIdxOrNot(frameCnt) & ~sp.updateOrNot(sp.trialIdx(frameCnt)) & (strcmp(kn, sp.respKeys{1})|strcmp(kn, sp.respKeys{2}))
        if kn == sp.respKeys{1}  % choose left
            if sp.loc(sp.trialIdx(frameCnt)) == 1% left is $20
                sp.winRecord(sp.trialIdx(frameCnt)) = sp.win{1}(sp.trialIdx(frameCnt));
                sp.choiceRecord(sp.trialIdx(frameCnt)) = 1; %20
                sp.cumMoney = sp.cumMoney + sp.moneyOffer(1) * sp.winRecord(sp.trialIdx(frameCnt));
            elseif sp.loc(sp.trialIdx(frameCnt)) == 2  % left is $5
                sp.winRecord(sp.trialIdx(frameCnt)) = sp.win{2}(sp.trialIdx(frameCnt));
                sp.choiceRecord(sp.trialIdx(frameCnt)) = 2; %5
                sp.cumMoney = sp.cumMoney + sp.moneyOffer(2) * sp.winRecord(sp.trialIdx(frameCnt));
            end
        elseif kn == sp.respKeys{2}  % choose right
            if sp.loc(sp.trialIdx(frameCnt)) == 1% right is $5
                sp.winRecord(sp.trialIdx(frameCnt)) = sp.win{2}(sp.trialIdx(frameCnt));
                sp.choiceRecord(sp.trialIdx(frameCnt)) = 2; %5
                sp.cumMoney = sp.cumMoney + sp.moneyOffer(2) * sp.winRecord(sp.trialIdx(frameCnt));
            elseif sp.loc(sp.trialIdx(frameCnt)) == 2  % right is $20
                sp.winRecord(sp.trialIdx(frameCnt)) = sp.win{1}(sp.trialIdx(frameCnt));
                sp.choiceRecord(sp.trialIdx(frameCnt)) = 1; %5
                sp.cumMoney = sp.cumMoney + sp.moneyOffer(1) * sp.winRecord(sp.trialIdx(frameCnt));
            end
        end
        sp.updateOrNot(sp.trialIdx(frameCnt)) = 1; % flag, already updated, no need to further update money
    end
    
    
    % write to file if desired
    if sp.wantFrameFiles
       imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',frameCnt));
    end
    
    % update when
    if didglitch
        % if there were glitches, proceed from our earlier when time.
        % set the when time to half a frame before the desired frame.
        % notice that the accuracy of the mfi is strongly assumed here.
        when = (when + mfi / 2) + mfi * sp.frameDuration - mfi / 2;
    else
        % if there were no glitches, just proceed from the last recorded time
        % and set the when time to half a frame before the desired time.
        % notice that the accuracy of the mfi is only weakly assumed here,
        % since we keep resetting to the empirical VBLTimestamp.
        when = VBLTimestamp + mfi * sp.frameDuration - mfi / 2;  % should we be less aggressive??
    end
    
    if sp.frameOrder(frameCnt) ~= 0
        Screen('Close', barTex1);
        Screen('Close', barTex2);
    end
    
end
toc
ptoff(oldclut);
%% clean up and save data
rmpath(genpath('./utils'));  % remove the utils path
c = fix(clock);
filename=sprintf('%d%02d%02d%02d%02d%02d_exp%s_subj%02d_run%02d',c(1),c(2),c(3),c(4),c(5),c(6),sp.expName,sp.subj,sp.runNo);
save(filename); % save everything to the file;
