function risetimes = FindPeakRiseTimes(data, pthresh, rthresh)
t = 1:1:length(data) ; y = data; n = numel(y);
yf = medfilt1(y,5); yf = medfilt1(yf,3);
yd = diff(yf);
ydf = medfilt1(yd,5); ydf = medfilt1(ydf,3);
yc = cummag(ydf); % see below
npeak = 0;
risetimes = [];
[ypeak, ipeak] = max(yc);
while (ypeak > pthresh)
    i = ipeak; % found peak, now look for rise time
    while (i>=1) && (yc(i)>rthresh)
        i = i-1;
    end
    if i>0
        npeak = npeak+1;
        risetimes(npeak)=t(i); %#ok<AGROW>
    end
% plot(t(1:end-1), yc);
% hold on;
% plot(t(ipeak),yc(ipeak),'r+');
% plot(t(i),yc(i),'g+');
% hold off;
% pause;
    i = ipeak;
    while (i>=1) && (yc(i)>0) % blank before peak
        yc(i) = 0;
        i = i-1;
    end
    i=ipeak;
    while (i<=n) && (yc(i)>0) % blank after peak
        yc(i) = 0;
        i = i+1;
    end
    [ypeak, ipeak] = max(yc);
end 

function yc = cummag(y)
yc = zeros(numel(y), 1);
s = 0;
for i = 1:numel(y)
    if y(i)>0
        s = s+y(i);
    else
        s = 0;
    end
    yc(i) = s;
end