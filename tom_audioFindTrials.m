function varargout = tom_audioFindTrials(varargin)
% TOM_AUDIOFINDTRIALS MATLAB code for tom_audioFindTrials.fig
%      TOM_AUDIOFINDTRIALS, by itself, creates a new TOM_AUDIOFINDTRIALS or raises the existing
%      singleton*.
%
%      H = TOM_AUDIOFINDTRIALS returns the handle to a new TOM_AUDIOFINDTRIALS or the handle to
%      the existing singleton*.
%
%      TOM_AUDIOFINDTRIALS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_AUDIOFINDTRIALS.M with the given input arguments.
%
%      TOM_AUDIOFINDTRIALS('Property','Value',...) creates a new TOM_AUDIOFINDTRIALS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom_audioFindTrials_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_audioFindTrials_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_audioFindTrials

% Last Modified by GUIDE v2.5 21-Jan-2016 16:25:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_audioFindTrials_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_audioFindTrials_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tom_audioFindTrials is made visible.
function tom_audioFindTrials_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_audioFindTrials (see VARARGIN)

% Choose default command line output for tom_audioFindTrials
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tom_audioFindTrials wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tom_audioFindTrials_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebuttonActivate.
function togglebuttonActivate_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonActivate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonActivate
act = get(hObject,'Value');
if act,
    set(hObject,'String','Select', 'BackgroundColor',[0.0 0.54 .54])
    [x,~] = ginput(1);
    hold(handles.axesAudio,'on')
    plot(handles.axesAudio,[x x],[-1000 1000],'r','linewidth',2)
    disp(x)
    handles.trialTimes = [handles.trialTimes; x];
    guidata(hObject, handles)
    set(hObject,'Value',0,'String','Activate Capture','BackgroundColor',[0.94 0.94 .94])
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderPos = get(hObject,'Value');
% newValues = round(length(handles.audio)*sliderPos);
% newValues = [newValues, newValues+handles.fs*10];
newValues = sliderPos*(length(handles.audio)/handles.fs);
newValues = [newValues, newValues+10];
xlim(handles.axesAudio, newValues)
ylim(handles.axesAudio, [-1 1])
drawnow

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trialTimes = handles.trialTimes * handles.fs;
for i = 1:(length(handles.trialTimes)-1),
    M(i,1) = handles.trialTimes(i,1);
    M(i,2) = handles.trialTimes(i+1,1);
end
lengthPrompt  = M(:,2) - M(:,1);
audio = handles.audio;
fs  = handles.fs;
uisave({'audio','fs','M','lengthPrompt','trialTimes'},'chopped_audio');

% --- Executes on button press in pushbuttonPlay.
function pushbuttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doPlay = get(hObject,'Value');
if doPlay==1,
    resume(handles.audioplayerHdl) 
    set(hObject,'String','Pause','BackgroundColor',[0 0.5 0.5])
    curTime = sprintf('%0.3g s', get(handles.audioplayerHdl,'CurrentSample')/handles.fs);
    set(handles.textPlayTime, 'String', curTime)     

    plotPlayIndicator(handles)
else
    pause(handles.audioplayerHdl)
    curTime = sprintf('%0.3g s', get(handles.audioplayerHdl,'CurrentSample')/handles.fs);
    set(handles.textPlayTime, 'String', curTime)     
    set(hObject,'String','Play', 'BackgroundColor',[0.94 0.94 .94])
end

function displayCurrentTime(handles)
curTime = sprintf('%0.3g s', get(handles.audioPlayerHdl,'CurrentSample')/handles.fs);
set(handles.textPlayTime, 'String', curTime) 
guidata(handles.textPlaytime, handles);

% --- Executes on button press in pushbuttonGetFile.
function pushbuttonGetFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGetFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axesAudio,'reset')
[filename, pathname] = uigetfile;
handles.file = [pathname, filename];
load(handles.file)

% check variable name
if ~exist('all_samples','var'),
    all_samples = audio;
end

% Normalize audio, if needed
if ~isfloat(all_samples)
    a = double(all_samples);
    minVal = find(zscore(a)<=-10,1); % clip anything below 10 SD
    handles.audio           = a / a(minVal);
    % handles.audio           = a / min(a);

    handles.audio(handles.audio >  1) = 1;
    handles.audio(handles.audio < -1) = -1;
else
    handles.audio = all_samples;
end
handles.fs              = 22000;
handles.trialTimes      = [];

% prepare the steps of the slider
set(handles.slider1,'SliderStep',[.01 .10])

% prepare the audio player
audioplayerHdl = audioplayer(handles.audio, handles.fs);
% By assigning a timer function to the audioplayer its activation should
% also call a second function, but ...
% timer_fcn = 'tom_audioFindTrials(''plotPlayIndicator(handles)'');';
% set(audioplayerHdl, 'TimerFcn', timer_fcn, 'TimerPeriod', 1);
% handles.myTimer = timer('TimerFcn',timer_fcn, 'Period', 1);

handles.audioplayerHdl = audioplayerHdl;
play(audioplayerHdl)
pause(audioplayerHdl)


% Plot waveform 
xdata = (1:length(handles.audio))/handles.fs;% sec
plot(handles.axesAudio, xdata, handles.audio)
xlim(handles.axesAudio, [0, 10])

plotPlayIndicator(handles)

guidata(hObject, handles)



function plotPlayIndicator(handles)
if nargin==0
    [h, figure] = gcbo;
end
% plot 'play' indicator
hold(handles.axesAudio,'on')
xval = get(handles.audioplayerHdl, 'CurrentSample');
if isfield(handles,'playIndx') && ishandle(handles.playIndx)
    set(handles.playIndx, 'XData',[xval, xval]./handles.fs)
else
    handles.playIndx = plot(handles.axesAudio,  [xval, xval]./handles.fs, [-.5, .5], 'g', 'linewidth', 2);
end
guidata(handles.axesAudio, handles)
