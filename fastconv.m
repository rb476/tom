function y = fastconv(x,h)
% linear convolution of x and h
% via the Fast Fourier Transform, a cost-saving method

[A,B] = size(x);
[C,D] = size(h);

if((A == D) || (B == C)) % if x and h are not the same dimension, display error message
   disp('WARNING in fastconv - input vectors are of different dimension')

else

l_x = length(x);
l_h = length(h);

% Length needed to achieve linear convolution (zpad)
N = l_x + l_h - 1;

% Zeropad to N  
x(l_x + 1: N) = 0;
h(l_h + 1: N) = 0;

% Calculate FFTs
X = fft(x, N);
H = fft(h, N);


% Sample-wise multiplication (dual of convolution in time)
Y = X .* H;

% Recover linear convolution of appropriate length
y = ifft(Y, N);

end
