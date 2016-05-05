function varargout = tom_audioParsing(varargin)
% TOM_AUDIOPARSING MATLAB code for tom_audioParsing.fig
%      TOM_AUDIOPARSING, by itself, creates a new TOM_AUDIOPARSING or raises the existing
%      singleton*.
%
%      H = TOM_AUDIOPARSING returns the handle to a new TOM_AUDIOPARSING or the handle to
%      the existing singleton*.
%
%      TOM_AUDIOPARSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_AUDIOPARSING.M with the given input arguments.
%
%      TOM_AUDIOPARSING('Property','Value',...) creates a new TOM_AUDIOPARSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom_audioParsing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_audioParsing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_audioParsing

% Last Modified by GUIDE v2.5 12-Jan-2016 15:02:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_audioParsing_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_audioParsing_OutputFcn, ...
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


% --- Executes just before tom_audioParsing is made visible.
function tom_audioParsing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_audioParsing (see VARARGIN)

% Choose default command line output for tom_audioParsing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tom_audioParsing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tom_audioParsing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonPlay.
function pushbuttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% t = handles.currentTrial;
% section = handles.trialTimes(t,1):handles.trialTimes(t,2);
% soundsc(handles.audio(section), handles.fs)
% % plot comet

%% to test the audio
tr = handles.currentTrial;
trialAudio = handles.audio(handles.trialTimes(handles.currentTrial,1):handles.trialTimes(handles.currentTrial,2));

for k = 1:5
    testseg = trialAudio( handles.trial(tr).promptTimes(k,1): handles.trial(tr).promptTimes(k,2));
    test = audioplayer(testseg, handles.fs);
    switch k
        case 1
            handles.trial(tr).Prompt = handles.trial(tr).promptTimes(k,:);
        case 2
            handles.trial(tr).Q1 = handles.trial(tr).promptTimes(k,:);
        case 3
            handles.trial(tr).A1 = handles.trial(tr).promptTimes(k,:);
        case 4
            handles.trial(tr).Q2 = handles.trial(tr).promptTimes(k,:);
        case 5
            handles.trial(tr).A2 = handles.trial(tr).promptTimes(k,:);
    end
    play(test)   % start the player
    pause
    set(handles.textPrompt,'String',sprintf('Currently playing section # %d',k))
end    


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% make sure we save everything...
for tr = 1:50,
    for k = 1:5
        if k==1
    handles.trial(tr).Prompt = handles.trial(tr).promptTimes(k,:);
        elseif k==2
    handles.trial(tr).Q1 = handles.trial(tr).promptTimes(k,:);
        elseif k==3
    handles.trial(tr).A1 = handles.trial(tr).promptTimes(k,:);
        elseif k==4
    handles.trial(tr).Q2 = handles.trial(tr).promptTimes(k,:);
        elseif k==5
    handles.trial(tr).A2 = handles.trial(tr).promptTimes(k,:);
        end
    end
end

BHV = handles.trial;
audio = handles.audio;
fs    = handles.fs;

uisave({'BHV','audio','fs'},'ToM_prompt_times')

% --- Executes on button press in pushbuttonBack.
function pushbuttonBack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentTrial - 1 > 0
    handles.currentTrial = handles.currentTrial - 1;
    % Plot waveform and spectrogram
    guidata(hObject, handles)
    updateTitle(handles)
    plotSpec(handles)
    plotWave(handles)
end


% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentTrial + 1 <= handles.trials
   
    handles.currentTrial = handles.currentTrial + 1;
    % Plot waveform and spectrogram
    guidata(hObject, handles)
    updateTitle(handles)
    plotSpec(handles)
    plotWave(handles)
end


% --- Executes on button press in pushbuttonGetFile.
function pushbuttonGetFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGetFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile;
handles.file = [pathname, filename];
load(handles.file)
handles.audio       = audio;
handles.fs          = fs;
if exist('M','var')
    handles.trialTimes  = M;    
else
    handles.trialTimes = trialTimes;
end
handles.trials      = length(trialTimes);

for i = 1:handles.trials,
    handles.trial(i).promptTimes = round(reshape(linspace(1,handles.fs*10,10),2,5))'; 
end
handles.currentTrial = 1;

% Plot waveform and spectrogram
guidata(hObject, handles)
updateTitle(handles)
plotSpec(handles)
plotWave(handles)
 
function plotSpec(handles)
trialAudio = handles.audio(handles.trialTimes(handles.currentTrial,1):handles.trialTimes(handles.currentTrial,2));
[~, f, t, p] = spectrogram(trialAudio, 500, 50, [], handles.fs);
surf(handles.axesSpectrogram, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
view(handles.axesSpectrogram, [0,90])
ylim(handles.axesSpectrogram, [0 1000])
xlim(handles.axesSpectrogram, [0, t(end)])

function plotWave(handles)
tr = handles.currentTrial;
color = ['r','g','m','c','y'];
% tdata = (1:length(handles.audio))/handles.fs;% sec
% increment = 200; % 10 ms increment in time when plotting
% step = handles.fs/(1000/increment) ; % ms

ydata = handles.audio(handles.trialTimes(tr,1):handles.trialTimes(tr,2));
xdata = (1:length(ydata));%/handles.fs;% sec

plot(handles.axesAudio, xdata, ydata)
ylim(handles.axesAudio,[-1 1])
xlim(handles.axesAudio,[1, numel(ydata)+1])

xx = handles.trial(tr).promptTimes;
for k = 1:5
    hold(handles.axesAudio,'on'), 
    plot(handles.axesAudio, xdata(xx(k,1):xx(k,2)),...
            ydata(xx(k,1):xx(k,2)),'color',color(k))
end    
hold(handles.axesAudio,'off'),
handles.trialAudio = ydata;
guidata(handles.axesAudio, handles)

function updateTitle(handles)
myText = sprintf('Current Trial %d out of %d', handles.currentTrial, handles.trials);
set(handles.textPromptNo, 'String', myText)

tr = handles.currentTrial;
promptText = mat2str(handles.trial(tr).promptTimes);
set(handles.textPromptTimes, 'String', promptText)

% --- Executes on button press in togglebuttonPrompt.
function togglebuttonPrompt_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonPrompt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonPrompt
act = get(hObject,'Value');
if act,
    tr = handles.currentTrial;
    [x, y] = ginput(2);
    handles.trial(tr).promptTimes(1,:) = round(x);
    guidata(hObject, handles)
    plotWave(handles)
    updateTitle(handles)
    set(hObject,'Value',0)
end
% --- Executes on button press in togglebuttonQ1.
function togglebuttonQ1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonQ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonQ1
act = get(hObject,'Value');
if act,
    tr = handles.currentTrial;
    [x, y] = ginput(2);
    handles.trial(tr).promptTimes(2,:) = round(x);
    guidata(hObject, handles)
    plotWave(handles)
    updateTitle(handles)
    set(hObject,'Value',0)
end

% --- Executes on button press in togglebuttonA1.
function togglebuttonA1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonA1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonA1

act = get(hObject,'Value');
if act,
    tr = handles.currentTrial;
    [x, y] = ginput(2);
    handles.trial(tr).promptTimes(3,:) = round(x);
    guidata(hObject, handles)
    plotWave(handles)
    updateTitle(handles)
    set(hObject,'Value',0)
end
% --- Executes on button press in togglebuttonQ2.
function togglebuttonQ2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
act = get(hObject,'Value');
if act,
    tr = handles.currentTrial;
    [x, y] = ginput(2);
    handles.trial(tr).promptTimes(4,:) = round(x);
    guidata(hObject, handles)
    plotWave(handles)
    updateTitle(handles)
    set(hObject,'Value',0)
end
% Hint: get(hObject,'Value') returns toggle state of togglebuttonQ2


% --- Executes on button press in togglebuttonA2.
function togglebuttonA2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonA2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
act = get(hObject,'Value');
if act,
    tr = handles.currentTrial;
    [x, y] = ginput(2);
    handles.trial(tr).promptTimes(5,:) = round(x);
    guidata(hObject, handles)
    plotWave(handles)
    updateTitle(handles)
    set(hObject,'Value',0)
end
% Hint: get(hObject,'Value') returns toggle state of togglebuttonA2
