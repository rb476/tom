function displayCurrentTime
figH = findobj('Tag','tom_audioFindTrials');
curTime = sprintf('%0.3g s', get(handles.audioPlayerHdl,'CurrentSample')/handles.fs);
set(handles.textPlayTime, 'String', curTime) 
guidata(handles.textPlaytime, handles);