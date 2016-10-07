fileID_dd = fopen(file_d);
A = textscan(fileID_dd, '%s %s %d %f %s', 'CollectOutput', 1);
fclose(fileID_dd);
Hz = nnz(strcmp(A{1,2},t{2}));
lfp = A{1,3};
audiowrite('test microphone.wav',lfp/max(lfp), Hz)