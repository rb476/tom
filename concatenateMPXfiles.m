function all_samples = concatenateMPXfiles(dataToMerge)
% Concatenates neuronal data originally in MPX files. Writes to file that can be
% imported by offline sorter (spikes) or read in Matlab (spikes/LFP).
%
%   all_samples = concatenateMPXfiles(dataToMerge)
%
% In: dataToMerge, string, {spikes,LFP,audio}
% 
% note that this function works with the MAT version of the MPX files. 
% 
% rbm 12.15

if nargin==0,
    dataToMerge = 'spikes';
end
   
%% Ask user to select files to merge
here = cd;
cd 'C:\Users\Raymundo\Documents\MGH\'
[files,pathname] = uigetfile('*.mat','Select files to merge','MultiSelect','on');
cd(here)
% if ~iscell(files) && files==0, return, end

%% Loop-read all files, concatenate all LFP/spike channels
all_samples = [];
for i = 1:length(files)
    load([pathname, files{i}])
    switch dataToMerge,
        case 'spikes'
            all_samples = [all_samples, [CSPK_01; CSPK_02; CSPK_03; CSPK_04; CSPK_05]];
        case 'LFP'
            all_samples = [all_samples, [CLFP_01; CLFP_02; CLFP_03; CLFP_04; CLFP_05]];
        case {'audio1','audio'}
            all_samples = [all_samples, CECOG_HF_1___01___Array_1___01];            
            fs = CECOG_HF_1___01___Array_1___01_KHz*1000;
        case 'audio2'
            all_samples = [all_samples, CECOG_HF_1___02___Array_1___02];
            fs = CECOG_HF_1___01___Array_1___01_KHz*1000;
    end
end

%% Write file ...
switch dataToMerge
    case 'LFP'
        fileName = input('Type in name for mat file (type within single quotation marks):  ');
        save(fileName, 'all_samples')
    case 'spikes'
        % NB: Once the continuously digitized data starts after the header, it
        %     cannot have any kind of “block structure” to it—it must contain just
        %     A/D values arranged in sweeps; each sweep contains a single A/D
        %     value from each channel.
        fileName = input('Type in name for "RAD" file (type within single quotation marks):  ');
        fileName = [fileName,'.rad'];

        [r, c] = size(all_samples);
        samplesInSweeps = reshape(all_samples,1,r*c);
        fid = fopen(fileName,'w');
        count = fwrite(fid, samplesInSweeps,'int16');
        status = fclose(fid);
         if status~=0,
            error('error closing RAD file'),
        else
            disp('Success concatenating files to RAD file')
         end
    case {'audio','audio1','audio2'}
        fileName = input('Type in name for audio file, follow the convention "session audio case X session Y.wav":   ');
        audiowrite(fileName, all_samples, fs, 'BitsPerSample',32);
end