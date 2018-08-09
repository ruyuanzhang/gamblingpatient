% This is the experiment program for gambling task on human brain. This
% project is conducted by Ruyuan Zhang (RZ). Ben Hayden and Ruyuan Zhang conceptualize and
% design the experiment.
%
% Some of the experiment paramteres are derived from the paper.
%
% History:
%   20180427 RZ updated
%       (1)Replace KbCheck with KbQueueCheck route.
%       (2)Constraint key press to some keys, see sp.allowedkeys
%       (3)
%   20180425 RZ created it.
%

%%
clear all;close all;clc;

sp.subj = input('Input the subj number: \n');
sp.runnum = input('Input the run number: \n');

addpath(genpath('./utils'));
%% debug purpose
sp.wantframefiles = 0;
sp.frameduration = 15;  % 120 monitor refresh
%mp = getmonitorparams('uminn7tpsboldscreen');
mp = getmonitorparams('uminnofficedesk');
sp.respkeys = {'1!','2@'};

%% monitor parameter (mp)
%mp = getmonitorparams('uminn7tpsboldscreen');
mp.monitorrect = [0 0 mp.resolution(1) mp.resolution(2)];

%% stimulus parameters (sp)
sp.expname = 'gambling';
sp.nTrial = 10;  % total 10 valid trial in a run.
sp.moneyoffer = [20, 5];
sp.prob = {rand(1,sp.nTrial), rand(1,sp.nTrial)};  % randomize probility for two offers
sp.posjitter = {rand(1,sp.nTrial), rand(1,sp.nTrial)};  % to gitter position a little bit.
sp.win = {ones(1,sp.nTrial), ones(1,sp.nTrial)}; % 1, win, 2, lose, for the two offers
sp.winornotintrial = zeros(1,sp.nTrial);  % record win or not in a trial;
design = getranddesign(sp.nTrial, [2 2]);
sp.loc = design(:,2); % 1,20 dollar offer on the left;2, 20 dollor offer on the right. 
sp.whofirst = design(:,3); % 1,20 dollar offer first;2, 5 dollor offer first. 
sp.colorintensity = 200; 
sp.color = {[0,sp.colorintensity, 0], [0,0,sp.colorintensity]};  % bar colors for 20 and 5.
sp.barbgcolor = [sp.colorintensity, 0, 0];
sp.ecc = 6; % deg
sp.barsize = [4.08, 11.35];  % width,height
sp.barlinewidth = 5; % pixels of the bar line Width
sp.stimtime = {[2,2],[2,2],[2,4]}; % secs, timing for three phases; [A,B], A is the stimulus onset time; B is blank
sp.fixsize = 10; % pixel, size of fixation dot
sp.fixcolor = {[255 255 255], [255, 0, 0]};
sp.grayval = 127;
sp.blackval = 0;
sp.whiteval = 254;

%% calculate more stimulus parameters
sp.eccpix = round(sp.ecc * mp.pixperdeg(1));
sp.barsizepix = round(sp.barsize * mp.pixperdeg(1));
sp.barrect = [0 0 sp.barsizepix(1) sp.barsizepix(2)]; % bar rect 
sp.barrectleft = CenterRect(sp.barrect, mp.monitorrect) + [-sp.eccpix 0 -sp.eccpix 0];   % bar rect on left of the screen
sp.barrectright = CenterRect(sp.barrect,mp.monitorrect) + [sp.eccpix 0 sp.eccpix 0];   % bar rect on left of the screen
sp.fixRect = CenterRect([0 0 sp.fixsize, sp.fixsize], mp.monitorrect);

%% make the stimulus images
% make $20 bar, red
bar20 = zeros([sp.barsizepix(2) sp.barsizepix(1) 3 sp.nTrial]);
%bar20(:, :, find(sp.barbgcolor>0), :) = sp.colorintensity;  % set the background color
%bar20(1:sp.barlinewidth, :, find(sp.color{1}>0), :) = sp.colorintensity;  % add border lines
%bar20(:, 1:sp.barlinewidth, find(sp.color{1}>0), :) = sp.colorintensity;
%bar20(end - sp.barlinewidth:end, :, find(sp.color{1}>0), :) = sp.colorintensity;
%bar20(:, end - sp.barlinewidth:end, find(sp.color{1}>0), :) = sp.colorintensity;
% fill color of the bar
for i=1:size(bar20, 4)
    %jitter = floor(sp.posjitter{1}(i) * sp.barsizepix(2)*(1- sp.prob{1}(i))) + 1;  % add position jitter within the bar
    bar20(1:round(sp.barsizepix(2)*sp.prob{1}(i)), :, find(sp.color{1}>0), i) = sp.colorintensity;
    bar20(round(sp.barsizepix(2)*sp.prob{1}(i))+1:end, :, find(sp.barbgcolor>0), i) = sp.colorintensity;
end

% make $5 bar, red
bar05 = zeros([sp.barsizepix(2) sp.barsizepix(1) 3 sp.nTrial]);
%bar05(:, :, find(sp.barbgcolor>0), :) = sp.colorintensity;  % set the background color

%bar05(1:sp.barlinewidth, :, find(sp.color{2}>0), :) = sp.colorintensity;
%bar05(:, 1:sp.barlinewidth, find(sp.color{2}>0), :) = sp.colorintensity;
%bar05(end - sp.barlinewidth:end, :, find(sp.color{2}>0), :) = sp.colorintensity;
%bar05(:, end - sp.barlinewidth:end, find(sp.color{2}>0), :) = sp.colorintensity;
% fill color of the bar
for i=1:size(bar05, 4)
    %jitter = floor(sp.posjitter{2}(i) * sp.barsizepix(2)*(1- sp.prob{2}(i))) + 1;  % add position jitter within the bar
    bar05(1:round(sp.barsizepix(2)*sp.prob{2}(i)), :, find(sp.color{2}>0), i) = sp.colorintensity;
    bar05(round(sp.barsizepix(2)*sp.prob{2}(i))+1:end, :, find(sp.barbgcolor>0), i) = sp.colorintensity;
end

sp.bar20 = bar20;
sp.bar05 = bar05;

%% make arguments for ptviewmovie function, saved as into stimulus parameters
% note that modified ptviewmoview.
% Here we define 'frame', which is not the 'frame' in terms of monitor
% refresh
% sense. It is smallest unit we gonna manipulate screen flip.
sp.blank = 16;  % secs, blanck at the begining and the end
%sp.frameduration = 120;  % 120 monitor refresh, that is one second / frame.
sp.stimunitsecs = sp.frameduration / mp.refreshRate;  % secs in a frame here

% now we compute the frameorderintrial, this part is difficult to understand
% from a reader's point of view, try to explain it more clear
sp.nframespersecs = mp.refreshRate / sp.frameduration; % how many image frames in a secs. Note that this is not monitor refresh rate
sp.trialevents = [1,0,2,0,3,0];  % just give a label to individual events in a trial. Here, 1:show offer 1;2, show offer2;3, show both offer;0, is blank.
sp.trialTime = [2, 2, 2, 2, 2, 4]; % lasting time of each event in sp.trialevents 
assert(length(sp.trialevents) == length(sp.trialTime));  % make sure then have same length
frameorderintrial = [];  % this is the event label in a trial
for i = 1:length(sp.trialevents)
    frameorderintrial = [frameorderintrial, repmat(sp.trialevents(i) * ones(1, sp.nframespersecs), [1, sp.trialTime(i)])];
end
sp.frameorder = repmat(frameorderintrial, [1, sp.nTrial]);  % we expand to nTrials
sp.trialidx = sort(mod(1:length(frameorderintrial) * sp.nTrial, sp.nTrial) + 1);   % give a trial label for all frameorder, sp.trialidx has equal length with sp.frameorder
tmp = frameorderintrial;
tmp(tmp~=3) = 0;
tmp(tmp==3) = 1;
tmp(end - sp.trialTime(end) * sp.nframespersecs + 1: end) = 1;
sp.checkwinidx = repmat(tmp, [1, sp.nTrial]);  % idx of frame to update the money
sp.totaltime = sum(sp.trialTime) * sp.nTrial + sp.blank * 2;  % secs, 12 seconds * nTrial + 16 blanks x 2 at beginging and end
%% MRI related preparation
% some auxillary variables
sp.timekeys = {};
sp.triggerkey = '5';
sp.timeframes=zeros(1, length(sp.frameorder));
sp.allowedkeys = zeros(1, 256);
sp.allowedkeys([20 41 30:34 89:93 79:80]) = 1;  %20,'q';41,'esc';89-93,'1'-'5';30-34, mackeyboard 1-5; 79-80, right/left keys
sp.moneywon = 0;
sp.updatedornot = zeros(1, sp.nTrial);  % a marker to show that already update money in this trial, more button press will not update again
getoutearly = 0;
when = 0;
glitchcnt = 0;
sp.devicenumber = 1; % devicenumber to record input
%kbQueuecheck setup
KbQueueCreate(1,sp.allowedkeys);

% get information about the PT setup
oldclut = pton([],[],[],1);
win = firstel(Screen('Windows'));
rect = Screen('Rect',win);
Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
mfi = Screen('GetFlipInterval',win);  % re-use what was found upon initialization!

%% wait for a key press to start, start to show stimulus
Screen('FillRect',win,sp.blackval,rect);
Screen('FrameOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));
Screen('TextSize',win,30);Screen('TextFont',win,'Arial');
Screen('DrawText', win, 'Waiting for experiment to start ...',rect(3)/2-250, rect(4)/2-50, 127);
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
      if isempty(sp.triggerkey) || isequal(temp(1),sp.triggerkey)
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
KbQueueStart(sp.devicenumber);
tic;
for framecnt = 1:length(sp.frameorder)

    if getoutearly
        break;
    end
    
    
    % figure the drawing type
    if sp.frameorder(framecnt) == 0  % blank image
        % in this case only draw a fixation point
        if sp.checkwinidx(framecnt) == 1 & ~sp.updatedornot(sp.trialidx(framecnt))  % in two offer phase, but not update the money (not respond yet)
            Screen('FillOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));  % 
        elseif sp.checkwinidx(framecnt) == 1 & sp.updatedornot(sp.trialidx(framecnt))  % already update
            if  sp.winornotintrial(sp.trialidx(framecnt)) == 1
                    Screen('FillOval', win, sp.fixcolor{2},CenterRect([0 0 sp.fixsize sp.fixsize], rect));  % subject win in this trial give feedback
            else
                Screen('FillOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));  % subject lose in this trial give feedback
            end
        else
            Screen('FrameOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));
        end
        Screen('DrawText', win, sprintf('$%d', sp.moneywon),rect(3)/2-25, rect(4)/2+50, 127);
    else
        % figure out the rect location and who comes first
        barrect1 = choose(sp.loc(sp.trialidx(framecnt))==1, sp.barrectleft, sp.barrectright);
        barrect2 = choose(sp.loc(sp.trialidx(framecnt))==1, sp.barrectright, sp.barrectleft);
        if sp.whofirst(sp.trialidx(framecnt)) == 1  % 20 dollor offer first
            barTex1 = Screen('MakeTexture',win,sp.bar20(:,:,:,sp.trialidx(framecnt)));
            barTex2 = Screen('MakeTexture',win,sp.bar05(:,:,:,sp.trialidx(framecnt)));
        elseif sp.whofirst(sp.trialidx(framecnt)) == 2 % 5 dollor offer first
            barTex1 = Screen('MakeTexture',win,sp.bar20(:,:,:,sp.trialidx(framecnt)));
            barTex2 = Screen('MakeTexture',win,sp.bar05(:,:,:,sp.trialidx(framecnt)));
        end
        
        % draw the texture
        if sp.frameorder(framecnt) == 1  % show first offer
            Screen('FrameOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));
            Screen('DrawTexture', win, barTex1, [], barrect1);
            Screen('DrawText', win, sprintf('$%d', sp.moneywon),rect(3)/2-25, rect(4)/2+50, 127);
        elseif sp.frameorder(framecnt) == 2  % show second offer
            Screen('FrameOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));
            Screen('DrawTexture', win, barTex2, [], barrect2);
            Screen('DrawText', win, sprintf('$%d', sp.moneywon),rect(3)/2-25, rect(4)/2+50, 127);
        elseif sp.frameorder(framecnt) == 3  % show both offer
            if  sp.winornotintrial(sp.trialidx(framecnt)) == 1
                Screen('FillOval', win, sp.fixcolor{2},CenterRect([0 0 sp.fixsize sp.fixsize], rect));  % subject win in this trial give feedback
            else
                Screen('FillOval', win, sp.fixcolor{1},CenterRect([0 0 sp.fixsize sp.fixsize], rect));  % subject lose in this trial give feedback
            end
            Screen('DrawTexture', win, barTex1, [], barrect1);
            Screen('DrawTexture', win, barTex2, [], barrect2);
            Screen('DrawText', win, sprintf('$%d', sp.moneywon),rect(3)/2-25, rect(4)/2+50, 127);
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
            sp.timeframes(framecnt) = VBLTimestamp;
            
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
            [keyIsDown,secs] = KbQueueCheck(sp.devicenumber);  % all devices, only check 'q','esc','1'-'5'
            if keyIsDown
                % get the name of the key and record it
                kn = KbName(secs);
                kn
                sp.timekeys = [sp.timekeys; {secs kn}];
                % check if ESCAPE was pressed
                if isequal(kn,'ESCAPE')
                    fprintf('Escape key detected.  Exiting prematurely.\n');
                    getoutearly = 1;
                    break;
                end
                
            end
          
        end
        
    end
    
    % update win and money
    % we update money, if: 
    % (1) in two-offer stage, sp.checkwinidx(framecnt) = 1
    % (2) no update in this trial, ~sp.updatedornot(sp.trialidx(framecnt))
    % (3) subject press the two designed button
    if sp.checkwinidx(framecnt) & ~sp.updatedornot(sp.trialidx(framecnt)) & (strcmp(kn, sp.respkeys{1})|strcmp(kn, sp.respkeys{2}))
        if kn == sp.respkeys{1}  % choose left
            if sp.loc(sp.trialidx(framecnt)) == 1% left is $20
                sp.winornotintrial(sp.trialidx(framecnt)) = sp.win{1}(sp.trialidx(framecnt));
                sp.moneywon = sp.moneywon + sp.moneyoffer(1) * sp.winornotintrial(sp.trialidx(framecnt));
            elseif sp.loc(sp.trialidx(framecnt)) == 2  % left is $5
                sp.winornotintrial(sp.trialidx(framecnt)) = sp.win{2}(sp.trialidx(framecnt));
                sp.moneywon = sp.moneywon + sp.moneyoffer(2) * sp.winornotintrial(sp.trialidx(framecnt));
            end
        elseif kn == sp.respkeys{2}  % choose right
            if sp.loc(sp.trialidx(framecnt)) == 1% right is $5
                sp.winornotintrial(sp.trialidx(framecnt)) = sp.win{2}(sp.trialidx(framecnt));
                sp.moneywon = sp.moneywon + sp.moneyoffer(2) * sp.winornotintrial(sp.trialidx(framecnt));
            elseif sp.loc(sp.trialidx(framecnt)) == 2  % right is $20
                sp.winornotintrial(sp.trialidx(framecnt)) = sp.win{1}(sp.trialidx(framecnt));
                sp.moneywon = sp.moneywon + sp.moneyoffer(1) * sp.winornotintrial(sp.trialidx(framecnt));
            end
        end
        sp.updatedornot(sp.trialidx(framecnt)) = 1; % flag, already updated, no need to further update money
    end
    
    
    % write to file if desired
    if sp.wantframefiles
       imwrite(Screen('GetImage',win),sprintf('Frame%03d.png',framecnt));
    end
    
    % update when
    if didglitch
        % if there were glitches, proceed from our earlier when time.
        % set the when time to half a frame before the desired frame.
        % notice that the accuracy of the mfi is strongly assumed here.
        when = (when + mfi / 2) + mfi * sp.frameduration - mfi / 2;
    else
        % if there were no glitches, just proceed from the last recorded time
        % and set the when time to half a frame before the desired time.
        % notice that the accuracy of the mfi is only weakly assumed here,
        % since we keep resetting to the empirical VBLTimestamp.
        when = VBLTimestamp + mfi * sp.frameduration - mfi / 2;  % should we be less aggressive??
    end
    
    if sp.frameorder(framecnt) ~= 0
        Screen('Close', barTex1);
        Screen('Close', barTex2);
    end
    
end
toc
ptoff(oldclut);
%% clean up and save data
rmpath(genpath('./utils'));  % remove the utils path
c = fix(clock);
filename=sprintf('%d%02d%02d%02d%02d%02d_exp%s_subj%02d_run%02d',c(1),c(2),c(3),c(4),c(5),c(6),sp.expname,sp.subj,sp.runnum);
save(filename); % save everything to the file;
