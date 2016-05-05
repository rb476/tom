clear all
load audio.mat
handelObj = audioplayer(audio, fs*1);
% Display some properties.
info = get(handelObj, {'SampleRate','BitsPerSample', 'NumberOfChannels'});
w = 2;
count = 0;
while w>1   
    count = count + 1;
    play(handelObj)   % start the player  
    
    w = waitforbuttonpress;
    if w == 1
        pause(handelObj)
    end
    MM(count,1) = get(handelObj,'CurrentSample');
    pause
    resume(handelObj)
    %     close(g cf)
    if count<51
        w = 2;
    end
end
save MM MM
%%
for i = 1:length(MM)-1
    M(i,1) = MM(i,1);
    M(i,2) = MM(i+1,1)-1;
end
LPrompt  = M(:,2) - M(:,1);
save audio audio t fs M LPrompt
%% to listen to a specific trial
figure,
i = input('Which Trial? ');
plot(audio(M(i,1):M(i,2)),'color',rand(3,1)), hold on
sound(audio(M(i,1):M(i,2)),fs)
%% to mark the beginning and the end of each Epoch 
clc
close all
clearvars -except audio M fs
color = ['r','g','m','c','y'];
% fs = 1*11000;
tdata = [1:length(audio)]/fs;% sec
increment = 200; % 10 ms increment in time when plotting
step = fs/(1000/increment) ; % ms
buffer = 20000;
for i = 43%:size(M,1)
    clear xdata ydata x y elapsedTime temp
    ydata = audio(M(i,1)-buffer:M(i,2)+buffer);
    xdata = [1:length(ydata)]/fs;% sec
%     spectrogram(ydata, 400, 300, [], fs, 'yaxis');caxis([-80 -30]);
    startSpot = 0;
    t = 1 ;
    x = 0 ;
    y = ydata(1);
    f = figure(1);
    plot(xdata(1:t),ydata(1:t));
%     axis([startSpot, xdata(end) , min(ydata) , max(ydata) ]); hold on
    PauseButton = uicontrol('Style', 'ToggleButton', ...
        'Units',    'pixels', ...
        'Position', [5, 5, 60, 20], ...
        'String',   'Pause', ...
        'Value',    1,...
        'Callback','uiresume(gcbf)');
    
    handelObj = audioplayer(ydata, fs*1);
    play(handelObj)   % start the player
    count = 1;
    ind = 0;
    while ( t < length(xdata))
        tic;
        plot(xdata(1:t),ydata(1:t));
        axis([startSpot, xdata(end) , min(ydata) , max(ydata) ]); 
        %         drawnow;
        elapsedTime(count,1)= toc;
        pause(increment/1000 - elapsedTime(count,1))
        if get(PauseButton, 'Value') == 0
            ind = ind +1 ;
            pause(handelObj)            
            temp(ind,1) = get(handelObj,'CurrentSample') + M(i,1) - 1;
            pause('on')
            uiwait(gcf)
            if  get(PauseButton, 'Value') == 1
                resume(handelObj)
            end
        end
        t = t + step;
        count = count + 1;
    end
    Segments(:,1) = temp(1:2:end,1) - M(i,1) + 1;
    Segments(:,2) = temp(2:2:end,1) - M(i,1) + 1;
    for j = 1:size(Segments,1)
        hold on, plot(xdata(Segments(j,1):Segments(j,2)),...
            ydata(Segments(j,1):Segments(j,2)),'color',color(j))
    end
    
    xx=[];yy=[];[xx,yy] = ginput2(10);
    xx = round(xx*fs);
    l = length(xx);
    figure,
    plot(xdata,ydata)
    for k = 1:l/2
        hold on, plot(xdata(xx(2*k-1):xx(2*k)),...
            ydata(xx(2*k-1):xx(2*k)),'color',color(k))
        Segments_new(k,1) = xx(2*k-1);
        Segments_new(k,2) = xx(2*k);
    end    
    Data(i,1).Segment = Segments_new + M(i,1) -1 -buffer;
    %% to test the audio
    for k = 1:5
        clear testseg test
        testseg = audio(Data(i).Segment(k,1):Data(i).Segment(k,2));
        test = audioplayer(testseg, fs*1);
        switch k
            case 1
                Data(i,1).Prompt = Data(i,1).Segment(k,:);
            case 2
                Data(i,1).Q1 = Data(i,1).Segment(k,:);
            case 3
                Data(i,1).A1 = Data(i,1).Segment(k,:);
            case 4
                Data(i,1).Q2 = Data(i,1).Segment(k,:);
            case 5
                Data(i,1).A2 = Data(i,1).Segment(k,:);
        end
        play(test)   % start the player
        pause
    end    
end
Fname = strcat('Data',num2str(i));
save(Fname,'Data')
% final figure
figure,
plot(tdata(M(i,1):M(i,2)),audio(M(i,1):M(i,2)))
for k = 1:size(Data(i).Segment,1)
    hold on, plot(tdata(Data(i).Segment(k,1):Data(i).Segment(k,2)),...
        audio(Data(i).Segment(k,1):Data(i).Segment(k,2)),'color',color(k))
end
 
%% to merge all the prompt ifos into a single file
clc
clear all
close all
for i = 1:50
    clearvars -except i BHV
    load(strcat('Data',num2str(i)))
    BHV(i,1) = Data(i,1);
end
save BHV BHV
