function varargout = tom_wordParsing(varargin)
% TOM_wordParsing MATLAB code for tom_wordParsing.fig
%      TOM_wordParsing, by itself, creates a new TOM_wordParsing or raises the existing
%      singleton*.
%
%      H = TOM_wordParsing returns the handle to a new TOM_wordParsing or the handle to
%      the existing singleton*.
%
%      TOM_wordParsing('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOM_wordParsing.M with the given input arguments.
%
%      TOM_wordParsing('Property','Value',...) creates a new TOM_wordParsing or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tom_wordParsing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tom_wordParsing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tom_wordParsing

% Last Modified by GUIDE v2.5 29-Mar-2016 18:24:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_wordParsing_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_wordParsing_OutputFcn, ...
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


% --- Executes just before tom_wordParsing is made visible.
function tom_wordParsing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_wordParsing (see VARARGIN)

% Choose default command line output for tom_wordParsing
handles.output = hObject;

handles.playspeed   = 1;
handles.thrsh       = 0.01;
handles.polyorder   = 3;
handles.frame       = 41;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tom_wordParsing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tom_wordParsing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoadWav.
function pushbuttonLoadWav_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.wav');
file = ([pathname filename]);
[y, fs] = audioread(file);
handles.audio = y;
handles.fs = fs;

[~, f, t, p] = spectrogram(y(fs*45:fs*55),100,90,512,fs);
surf(handles.axesAudio, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
view(handles.axesAudio, [0,90])
ylim(handles.axesAudio, [0 fs/2])
xlim(handles.axesAudio, [0, t(end)])

set(handles.textLoadWav, 'String', (['Loaded ',filename(1:end-4)]), 'foreground', 'Red')

guidata(hObject, handles)

% --- Executes on button press in pushbuttonLoadExcel.
function pushbuttonLoadExcel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.xls;*.xlsx');
handles.xlsfile = [pathname, filename];
text = cell(50, 5);
textstr = [];

if isfield(handles, 'sheetnum') == 0
    set(handles.textLoadExcel,'String',sprintf('Define Session Number!'))
elseif strcmp('Session Number', handles.sheetnum) == 1
    set(handles.textLoadExcel,'String',sprintf('Define Session Number!'))
else
    sheetnum = str2double(handles.sheetnum);
    [num, txt, raw] = xlsread(handles.xlsfile, sheetnum);
    
    % find columns to extract text        
    try
        text(:, 1) = txt(2:end, strcmpi(txt(1,:),'Trunk text'));
        text(:, 2) = txt(2:end, strcmpi(txt(1,:),'Question 1'));
        text(:, 3) = txt(2:end, strcmpi(txt(1,:),'Answer 1'));
        text(:, 4) = txt(2:end, strcmpi(txt(1,:),'Question 2'));
        text(:, 5) = txt(2:end, strcmpi(txt(1,:),'Answer 2'));
    catch
        warning('Error extracting text from worksheet, probably columns aren''t properly labelled')
        rethrow(lasterror)
    end
    
    for i = 1:length(text)
        textdum = strjoin(text(i,:), '  ');
        textstr = [textstr ' ' textdum];
    end
    
    wordloc = zeros(1,length(regexp(textstr, ' '))+1); wordloc(1,1) = 1;
    wordloc(1, 2:end) = regexp(textstr, ' '); wordloc(1, end+1) = length(textstr); wordloc(1,1) = 1;
    
    wordpred = cell(length(wordloc)-1, 1);
    wordpred(1, 1) = cellstr(textstr(wordloc(1):wordloc(2)-1));
    for i =2:length(wordloc)-2
        wordpred(i, 1) = cellstr(textstr(wordloc(i)+1:wordloc(i+1)-1));
    end
    wordpred(i+1, 1) = cellstr(textstr(wordloc(i+1)+1:wordloc(i+2)));
    wordpred(cellfun(@isempty,wordpred)) = [];
    handles.wordpred = wordpred;
    
    set(handles.uitableWords, 'Data', wordpred);
    set(handles.textLoadExcel,'String',(['Loaded ',filename(1:end-4), ' Session ' handles.sheetnum]), 'foreground', 'Green')
    
    guidata(hObject, handles)
end

% --- Executes on selection change in popupmenu_SessionNum.
function popupmenu_SessionNum_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_SessionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_SessionNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_SessionNum

contents = cellstr(get(hObject,'String'));
sessionnum = contents{get(hObject,'Value')};
handles.sheetnum = sessionnum;

guidata(hObject, handles)

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
    plotWave(handles)
end
 
% function plotSpec(handles)
% trialAudio = handles.audio(handles.trialTimes(handles.currentTrial,1):handles.trialTimes(handles.currentTrial,2));
% [~, f, t, p] = spectrogram(trialAudio, 500, 50, [], handles.fs);
% surf(handles.axesSpectrogram, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
% view(handles.axesSpectrogram, [0,90])
% ylim(handles.axesSpectrogram, [0 1000])
% xlim(handles.axesSpectrogram, [0, t(end)])

function plotSpec(handles)
trialAudio = handles.audio(handles.trialTimes(handles.currentTrial,1):handles.trialTimes(handles.currentTrial,2));
[~, f, t, p] = spectrogram(trialAudio, 500, 50, [], handles.fs);
surf(handles.axesSpectrogram, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
view(handles.axesSpectrogram, [0,90])
ylim(handles.axesSpectrogram, [0 1000])
xlim(handles.axesSpectrogram, [0, t(end)])

% --- Executes during object creation, after setting all properties.
function popupmenu_SessionNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_SessionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonLowBP.
function pushbuttonLowBP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLowBP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fs = handles.fs;
fNorm = 4000 / (fs/2);
[b, a] = butter(10, fNorm, 'low');
handles.audio_lbp = filtfilt(b, a, handles.audio);

[~, f, t, p] = spectrogram(handles.audio_lbp(fs*45:fs*55),100,90,512,handles.fs);
surf(handles.axesAudio, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
view(handles.axesAudio, [0,90])
ylim(handles.axesAudio, [0 10000])
xlim(handles.axesAudio, [0, t(end)])

set(handles.textLowBP, 'String', ('DONE!'), 'foreground', 'Green')

guidata(hObject, handles)




% --- Executes on button press in pushbuttonHighBP.
function pushbuttonHighBP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonHighBP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fs = handles.fs;
fNorm = 100 / (fs/2);
[b, a] = butter(8, fNorm, 'high');
handles.audio_bp = filtfilt(b, a, handles.audio_lbp);

[~, f, t, p] = spectrogram(handles.audio_lbp(fs*45:fs*55),100,90,512,handles.fs);
surf(handles.axesAudio, t(:), f(:), 10*log10(abs(p)), 'EdgeColor', 'none')
view(handles.axesAudio, [0,90])
ylim(handles.axesAudio, [0 10000])
xlim(handles.axesAudio, [0, t(end)])

set(handles.textHighBP, 'String', ('DONE!'), 'foreground', 'Green')

guidata(hObject, handles)


% --- Executes on button press in pushbuttonStrtEnd.
function pushbuttonStrtEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStrtEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.wordTimes=[];

% fs = handles.fs;
if isfield(handles, 'audio_bp') == 1
    e = handles.audio_bp;
else
    e = handles.audio;
end

[strt, ct] = findstrtend(e, handles);

handles.wordTimes(:,1) = strt;
handles.wordTimes(:,2) = ct;
handles.y = e;

plot(handles.axesAudio, 1:length(e), e);
hold(handles.axesAudio,'on')
mins = e(handles.wordTimes(:,1));
maxs = e(handles.wordTimes(:,2));
xlim ([0 length(e)])
ylim([-1 1])
scatter(handles.axesAudio, handles.wordTimes(:,1), mins, 'foreground', 'green')
scatter(handles.axesAudio, handles.wordTimes(:,2), maxs, 'foreground', 'red')
hold(handles.axesAudio,'off')

str = (['DONE! ' num2str(length(mins)) ' words found']);
set(handles.textStrtEnd, 'String', str, 'foreground', 'Green')

set(handles.uitableTimes, 'Data', handles.wordTimes);
a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});

guidata(hObject, handles)


% --- Executes on button press in pushbuttonLoadStrEnd.
function pushbuttonLoadStrEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadStrEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.wordTimes = [];
[filename, pathname] = uigetfile('*.mat');
load([pathname, filename]);

handles.wordTimes = wordTimes;
a = 1:length(wordTimes); a = a';

set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', wordTimes);

% update "predicted" words 
handles.wordpred = wordPred;
set(handles.uitableWords, 'Data', wordPred);  

guidata(hObject, handles)


function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double
input = get(hObject,'String');
handles.thrsh = str2double(input);

guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [strt, ct] = findstrtend(signal, handles)

if isfield(handles,'thrsh') == 0
    handles.thrsh = .01;
end

if isfield(handles,'polyorder') == 0
    handles.polyorder = 3;
end

if isfield(handles,'frame') == 0
    handles.frame = 41;
end
guidata(gcbo, handles);

fs = handles.fs;
e = sgolayfilt(signal, handles.polyorder, handles.frame);

eSq = e.*e;
eSq = eSq/(max(abs(eSq)));
% 
% for i = 1:length(eSq)
%     if eSq(i) > .1
%         eSq(i) = .1;
%     elseif eSq(i) < -.1
%         eSq(i) = -.1;
%     elseif abs(eSq(i)) < .02
%         eSq(i) = 0;
%     end
% end

% eSq(eSq > 0.1)  = 0.1;
% eSq(eSq < 0.02) = 0;

eSq(eSq > 0.1)  = 0.1;
eSq(eSq < 0.005) = 0;

t=0:1/fs:(length(eSq)-1)/fs;
S = ones(512/2,1);

set(handles.textStrtEnd, 'String', ...
    'Performing Convolution...', 'foreground', 'red'), pause(.5);

env = fastconv(abs(eSq),S);
env = env/max(abs(env)) * .1;
% trim envelope to the length of the signal
env((length(signal)+1):end) = [];
th = .1 * handles.thrsh;

% counter variables
s_index = 1;
c_index = 1;

pos_edge = 1; % searching for positive or negative zero crossing
loc = 1; % current sample
strt = [ ]; % beginning of word in envelope
ct = [ ]; % end of word in envelope

while loc < length(env)
    
    if pos_edge == 1 % looking for a positive threshold crossing
        I = (loc-1)+ find(env(loc:end) > th , 1); % find crossing
        if isempty(I) % cancel search if no crossing found
            break
        end
        strt(s_index)= I; % keep track of crossing location
        s_index = s_index + 1;
        pos_edge = 0; % start looking for negative crossings
%         loc = I + fs/10; % skip ahead 100 ms to avoid noisy behavior
        loc = I + fs/100; % skip ahead 10 ms to avoid noisy behavior
        
    elseif pos_edge == 0 % looking for a negative threshold crossing
        
        G = (loc-1) + find(env(loc:end) < th , 1);
        if isempty(G)
            if length(strt) > length(ct)
                ct(c_index) = length(env)-1;
            end              
            break
        end
        ct(c_index)= G;
        c_index = c_index + 1;
        pos_edge = 1;
        loc = G + fs/10;
        set(handles.textStrtEnd, 'String', (['Finding word...' num2str(c_index)]), 'foreground', 'blue'), pause(.01);
    end    
end




function order_Callback(hObject, eventdata, handles)
% hObject    handle to order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of order as text
%        str2double(get(hObject,'String')) returns contents of order as a double
input = get(hObject,'String');
handles.order = str2double(input);

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function order_CreateFcn(hObject, eventdata, handles)
% hObject    handle to order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame as text
%        str2double(get(hObject,'String')) returns contents of frame as a double
input = get(hObject,'String');
handles.frame = str2double(input);

guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonTestParam.
function pushbuttonTestParam_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonTestParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.wordTimes=[];
fs = handles.fs;
if isfield(handles, 'audio_bp') == 1
    e = handles.audio_bp(fs*60:fs*80);
else
    e = handles.audio(fs*60:fs*80);
end
handles.y = e;

[strt, ct] = findstrtend(handles.y, handles);

handles.wordTimes(:,1) = strt;
handles.wordTimes(:,2) = ct;

plot(handles.axesAudio, 1:(length(e)), e);
hold(handles.axesAudio,'on')
mins = e(strt);
maxs = e(ct);
scatter(handles.axesAudio, strt, mins, 'foreground', 'green')
scatter(handles.axesAudio, ct, maxs, 'foreground', 'red')
hold(handles.axesAudio,'off')

a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', handles.wordTimes);

set(handles.textStrtEnd, 'String', ('Testing Parameters DONE!'), 'foreground', 'black')

guidata(hObject, handles)


% --- Executes on button press in pushbuttonSaveWordTimes.
function pushbuttonSaveWordTimes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveWordTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wordTimes = handles.wordTimes;
wordPred = handles.wordpred;

uisave({'wordTimes', 'wordPred'},'ToM_Word_strt_end_times')


% --- Executes on button press in pushbuttonPlaySegment.
function pushbuttonPlaySegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlaySegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.playaudio = [];
fs = handles.playspeed*handles.fs;
handles.playaudio = audioplayer(handles.y, fs);
play(handles.playaudio);

guidata(hObject, handles)


% --- Executes on button press in pushbuttonStopSound.
function pushbuttonStopSound_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStopSound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(handles.playaudio);
guidata(hObject, handles)


% --- Executes on button press in pushbuttonResume.
function pushbuttonResume_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resume(handles.playaudio);
guidata(hObject, handles)



function editPlaySpeed_Callback(hObject, eventdata, handles)
% hObject    handle to editPlaySpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPlaySpeed as text
%        str2double(get(hObject,'String')) returns contents of editPlaySpeed as a double
input = get(hObject,'String');
handles.playspeed = str2double(input);

guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function editPlaySpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPlaySpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxNumWords.
function listboxNumWords_Callback(hObject, eventdata, handles)
% hObject    handle to listboxNumWords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxNumWords contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxNumWords
handles.y=[];
fs = handles.fs;
wordnum = get(hObject,'Value');
handles.wordNum = wordnum;

if handles.wordTimes(wordnum,2) == 0
    set(handles.editStart, 'String', num2str(handles.wordTimes(wordnum,1)));
    set(handles.editEnd, 'String', num2str(handles.wordTimes(wordnum,2)));
    msgbox('Edit Start and End Times!')
else
    set(handles.editStart, 'String', num2str(handles.wordTimes(wordnum,1)));
    set(handles.editEnd, 'String', num2str(handles.wordTimes(wordnum,2)));
    handles.wordWindow = handles.wordTimes(wordnum,1)-(fs/5);
    if handles.wordWindow < 0, handles.wordWindow = 1; end
    e = handles.audio(handles.wordWindow:(handles.wordTimes(wordnum,2)+(fs/5)));
   
    handles.y = e;
    wordStart = handles.wordTimes(wordnum,1);
    wordEnd   = handles.wordTimes(wordnum,2);
    buffer    = fs/2;
    handles.yword = handles.audio(wordStart:wordEnd);
    
    % Plot scatter of all words, this resets all word markers to circles
    plot(handles.axesAudio, handles.audio)
    hold(handles.axesAudio,'on')
    mins = handles.audio(handles.wordTimes(:,1));
    maxs = handles.audio(handles.wordTimes(:,2));
    scatter(handles.axesAudio, handles.wordTimes(:,1), mins, 'foreground', 'green')
    scatter(handles.axesAudio, handles.wordTimes(:,2), maxs, 'foreground', 'red')

    
    xlim([wordStart-buffer wordEnd+buffer])
%     plot(handles.axesAudio, 1:length(e), e);
    mins = handles.audio(handles.wordTimes(wordnum,1));
    maxs = handles.audio(handles.wordTimes(wordnum,2));
%     xlim ([0 length(e)])
    ylim([-1 1])
    handles.ws_hdl = scatter(handles.axesAudio, wordStart, mins, 100,'dg','filled');
    handles.we_hdl = scatter(handles.axesAudio, wordEnd, maxs, 100, 'dr','filled');

%     scatter(handles.axesAudio, fs/5, mins, 'foreground', 'green')
%     scatter(handles.axesAudio, fs/5+(handles.wordTimes(wordnum,2)-handles.wordTimes(wordnum,1)), maxs, 'foreground', 'red')
    hold(handles.axesAudio,'off')
    
    % change title to reflect expected word and word number
    title(handles.axesAudio, sprintf('Word # %d. "%s"', handles.wordNum, ...
        handles.wordpred{handles.wordNum}))
end

guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function listboxNumWords_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxNumWords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddRow.
function pushbuttonAddRow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get new times
[x,~] = ginput(2);
wordLimits = round(x(:)');

% plot them
hold(handles.axesAudio,'on')
scatter(handles.axesAudio, wordLimits(:)', handles.audio(wordLimits)',500,'.k')
hold(handles.axesAudio,'off')

data = get(handles.uitableTimes, 'data');
wordnum = handles.wordNum;

data = [data(1:wordnum,:); wordLimits; data(wordnum+1:end,:)];
handles.wordTimes = data;

a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', handles.wordTimes);

guidata(hObject, handles)



% --- Executes on button press in pushbuttonDelWord.
function pushbuttonDelWord_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.uitableTimes, 'data');
wordnum = handles.wordNum;

data(wordnum,:) = [];
handles.wordTimes = data;

a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', handles.wordTimes);

guidata(hObject, handles)


function editStart_Callback(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStart as text
%        str2double(get(hObject,'String')) returns contents of editStart as a double


% --- Executes during object creation, after setting all properties.
function editStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editEnd_Callback(hObject, eventdata, handles)
% hObject    handle to editEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEnd as text
%        str2double(get(hObject,'String')) returns contents of editEnd as a double


% --- Executes during object creation, after setting all properties.
function editEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonEditStart.
function pushbuttonEditStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEditStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x, ~] = ginput(1);
% newstart = round(x)+handles.wordWindow;

data = get(handles.uitableTimes, 'data');
wordnum = handles.wordNum;
% data(wordnum,1) = newstart;
data(wordnum,1) = round(x);

% change yword
handles.yword = handles.audio(data(wordnum,1):data(wordnum,2));

handles.wordTimes = data;
a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', handles.wordTimes);

% Re-plot scatter dot
handles.ws_hdl.XData = round(x);
handles.ws_hdl.YData = handles.audio(round(x));

guidata(hObject, handles)


% --- Executes on button press in pushbuttonEditEnd.
function pushbuttonEditEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEditEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x, ~] = ginput(1);
% newstart = round(x)+handles.wordWindow;

data = get(handles.uitableTimes, 'data');
wordnum = handles.wordNum;
data(wordnum,2) = round(x);

% change yword
handles.yword = handles.audio(data(wordnum,1):data(wordnum,2));

handles.wordTimes = data;
a = 1:length(handles.wordTimes); a = a';
set(handles.listboxNumWords, 'String', {a});
set(handles.uitableTimes, 'Data', handles.wordTimes);

% Re-plot scatter dot
handles.we_hdl.XData = round(x);
handles.we_hdl.YData = handles.audio(round(x));

guidata(hObject, handles)

% --- Executes on button press in pushbuttonPlayWord.
function pushbuttonPlayWord_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlayWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.playaudio = [];
fs = handles.playspeed*handles.fs;
handles.playaudio = audioplayer(handles.yword, fs);
play(handles.playaudio);

guidata(hObject, handles)


% --- Executes on button press in pushbuttonPreviousWord.
function pushbuttonPreviousWord_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPreviousWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = handles.wordNum-1;
if w >=0,
    handles.listboxNumWords.Value = w;
    guidata(gcbo,handles)
    listboxNumWords_Callback(handles.listboxNumWords, eventdata, handles)
end
    
% --- Executes on button press in pushbuttonNextWord.
function pushbuttonNextWord_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNextWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = handles.wordNum+1;
if w <= max([length(handles.wordpred), length(handles.wordTimes)]),
    handles.listboxNumWords.Value = w;
    guidata(gcbo,handles)
    listboxNumWords_Callback(handles.listboxNumWords, eventdata, handles)
end


% --- Executes when entered data in editable cell(s) in uitableWords.
function uitableWords_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitableWords (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
R = eventdata.Indices;

handles.wordpred{R(1)} = eventdata.EditData;
guidata(gcbo, handles)


% --- Executes on button press in pushbuttonAddMissingWord.
function pushbuttonAddMissingWord_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddMissingWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Generate a new row
oldTable = handles.wordpred;
newTable = [oldTable(1:handles.wordNum); {''};oldTable(handles.wordNum+1:end)];
handles.uitableWords.Data = newTable;
handles.wordpred = newTable;
guidata(gcbo, handles)

% Look up the start and end times
pushbuttonAddRow_Callback(handles.pushbuttonAddRow, [], handles)
guidata(gcbo, handles)

