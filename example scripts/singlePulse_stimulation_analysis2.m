function output = singlePulse_stimulation_analysis2(individual_traces, time, sr, RsStart)

%new version of LED_VCTrace_CorrBase.m (created and updated by Naoki Yamawaki, 1/27/16)
%need input arguments individual_traces, time and RsStart
%it will generate:
%1)a structure called "SinglePulseData' containing multiple information of raw and processed data and measurement
%2)a figure containing raw, baseline subtracted, and mean trace and peak/mean amplitude of EPSC or IPSC (with series resistance for each sweep)
%Note rise time currently only works for input with size well above noise
%==========================================================================
%user defined variables. To do: read stim onset from data file automatically
cellID         = 3700;
rec_mode       = 'IC'
y_unit         = 'mV';  %for figure y-axis label
stim_onset     = 0.1;   %in second
analysis_width = 0.1;          %in second
% sr             = 10000;         %sampling rate
voltage_stp    = -5;            %in mV
stp_duration   = 0.05;          %in second
%==========================================================================

w_1 = stim_onset*sr; %stim onset into sampling points
w_2 = (stim_onset+analysis_width)*sr ;%end smapling point of analysis window
x_range = w_2-w_1+1;
%==========================================================================
traceNumber = size(individual_traces,2);

for k=1:traceNumber,
    Ihold(:,k) = nanmean(individual_traces(1:(stim_onset*sr-1),k));
    traces(:,k) = individual_traces(:,k)-Ihold(:,k);
end

Ihold_mean = nanmean(Ihold);%mean holding current

%==========================================================================
%calculation from averaged trace (mean and peak (E/IPSC/P)

%mean trace=========
averageTrace = nanmean(traces,2);
averageTrace_filtered = gfilter(averageTrace,5,'median');
mean_amp = nanmean(averageTrace(w_1:w_2,:)); %mean amp from mean trace

if mean_amp < 0,
    peak_amp = min(averageTrace_filtered(w_1:w_2,:));
else
    peak_amp = max(averageTrace_filtered(w_1:w_2,:));
end


%median trace=========
medianTrace = nanmedian(traces,2);
mean_amp_med = nanmean(medianTrace(w_1:w_2,:)); %mean amp from median trace

if mean_amp_med < 0,
    peak_amp_med = min(medianTrace(w_1:w_2,:));
else
    peak_amp_med = max(medianTrace(w_1:w_2,:));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculation from individual traces (mean and peak E/IPSC/P)
for k=1:traceNumber,
    individual_mean_amp(:,k)= nanmean(traces(w_1:w_2,k));
    
   if mean_amp < 0,
    individual_peak_amp(:,k)= min(traces(w_1:w_2,k));
   else 
    individual_peak_amp(:,k)= max(traces(w_1:w_2,k));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rs calculation

stp_duration=stp_duration*sr;%multiplied by sampling rate
RsStart=RsStart(1,1);
RsStart=RsStart*sr;
RsEnd=RsStart+stp_duration;

%for k=1:traceNumber,    
%    capacitative_current(:,k) = min(traces(RsStart:RsEnd,k));
%end %find peak cap current within 5ms
    
%for k=1:traceNumber
%    Rs(:,k) = 1000*voltage_stp/capacitative_current(:,k);
%end

%Rs_mean = nanmean(Rs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculation of peak time and rise time (10-90% peak)

%mean trace
peak_amp_time = time(averageTrace_filtered(w_1:w_2,:) == peak_amp);%find t where peak amp is found from stim onset

%median trace
peak_amp_time_med = time(medianTrace(w_1:w_2,:) == peak_amp_med);

%mean trace
a = peak_amp*10;%peak_amp back to sampling points (from stim onset)
b = peak_amp_time*10;%peak_amp_time back to sampling points (from stim onset)

%median trace
c = peak_amp_med*10;%peak_amp back to sampling points (from stim onset)
d = peak_amp_time_med*10;%peak_amp_time back to sampling points (from stim onset)

%mean trace
if size(b,2)>1,
    b = b(1,1);
else
    b = b;
end

%median trace
if size(d,2)>1,
    d = d(1,1);
else
    d = d;
end

%mean trace
peak_amp_10 = peak_amp*0.1; %10% of peak amp
peak_amp_90 = peak_amp*0.9; %90% of peak amp

%median trace
peak_amp_10_med = peak_amp_med*0.1; %10% of peak amp
peak_amp_90_med = peak_amp_med*0.9; %90% of peak amp

%mean trace:
dif_10 = abs(averageTrace_filtered(w_1:w_2) - peak_amp_10);
dif_90 = abs(averageTrace_filtered(w_1:w_2) - peak_amp_90);

%median trace
%dif_10_med = abs(medianTrace(w_1:w_2) - peak_amp_10_med);
%dif_90_med = abs(medianTrace(w_1:w_2) - peak_amp_90_med);

%dif_10 = flipud(dif_10);
%keyboard
%mean trace
time_point_10 = time(dif_10 == min(dif_10(1:b,:)));%search between stim onset and peak for mean trace
time_point_90 = time(dif_90 == min(dif_90(1:b,:)));%search between stim onset and peak for mean trace
peak_amp_10_actual = min(dif_10(1:b,:))+peak_amp_10;
%peak_amp_10_actual = -(min(dif_10(1:b,:))-peak_amp_10);
%peak_amp_90_actual = min(dif_90(1:b,:))+peak_amp_90;
peak_amp_90_actual = -(min(dif_90(1:b,:))-peak_amp_90);

%median trace
%time_point_10_med = time(dif_10_med == min(dif_10_med(1:d,:)));%search between stim onset and peak for mean trace
%time_point_90_med = time(dif_90_med == min(dif_90_med(1:d,:)));%search between stim onset and peak for mean trace

 
%mean trace
if size(peak_amp_time,2)>1,
    peak_amp_time = peak_amp_time(1,1);
else
    peak_amp_time = peak_amp_time;
end

%median trace
%if size(peak_amp_time_med,2)>1,
%    peak_amp_time_med = peak_amp_time_med(1,1);
%else
%    peak_amp_time_med = peak_amp_time_med;
%end

%keyboard
%mean trace
if size(time_point_10,2)>1,
    time_point_10 = time_point_10(1,1);
else
    time_point_10 = time_point_10;
end

%median trace
%if size(time_point_10_med,2)>1,
%    time_point_10_med = time_point_10_med(1,1);
%else
%    time_point_10_med = time_point_10_med;
%end


%mean trace
if size(time_point_90,2)>1,
    time_point_90 = time_point_90(1,1);
else
    time_point_90 = time_point_90;
end

%median trace
%if size(time_point_90_med,2)>1,
%    time_point_90_med = time_point_90_med(1,1);
%else
%    time_point_90_med = time_point_90_med;
%end

%keyboard

%mean trace
peak_amp_time = peak_amp_time + (w_1-1)/10;%add baseline
peak_amp_time_10 = time_point_10 + (w_1-1)/10;%add baseline
peak_amp_time_90 = time_point_90 + (w_1-1)/10;%add baseline


%median trace
%peak_amp_time_med = peak_amp_time_med + w_1/10;%add baseline
%peak_amp_time_10_med = time_point_10_med + w_1/10;%add baseline
%peak_amp_time_90_med = time_point_90_med + w_1/10;%add baseline



%mean trace
rise_time = peak_amp_time_90 - peak_amp_time_10;

%median trace
%rise_time_med = peak_amp_time_90_med - peak_amp_time_10_med;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Plot figures
figure;set(gcf,'numbertitle','off','name',strcat('ny',int2str(cellID),' :',char(rec_mode)));
       subplot(2,3,1)
       plot(time,individual_traces);
       title('individulal traces','fontweight','b');
       xlabel('ms');ylabel(char(y_unit));
       vline(w_1/10,'k:');hold on;vline(w_2/10,'k:');box off
       
       subplot(2,3,2),
       plot(time,traces);
       title('baseline subtracted','fontweight','b');
       xlabel('ms');ylabel(char(y_unit));box off
       
       subplot(2,3,3),
       
       %mean
       plot(time,averageTrace,'k');hold on
       plot(time,averageTrace_filtered,'r');hold on
       plot(peak_amp_time_10, peak_amp_10_actual,'ob','markersize',8);hold on;
       plot(peak_amp_time_90, peak_amp_90_actual,'ob','markersize',8);hold on;
       plot(peak_amp_time, peak_amp,'ob','markersize',8);
       
       %median 
      % plot(time,medianTrace,'r');hold on
      % plot(peak_amp_time_10_med, peak_amp_10_med,'og','markersize',8);hold on;
      % plot(peak_amp_time_90_med, peak_amp_90_med,'og','markersize',8);hold on;
      % plot(peak_amp_time_med, peak_amp_med,'og','markersize',8);
       
       title('mean/median trace','fontweight','b');
       xlabel('ms');ylabel(char(y_unit));
       vline(w_1/10,'k:');hold on;vline(w_2/10,'k:');box off
       
       
       
       subplot(2,3,4),
%       plot(Rs,'ok');
%       title('series','fontweight','b');
%       xlabel('sweep');ylabel('M{\Omega}');box off
       
       subplot(2,3,5),
       plot(individual_peak_amp,'or');box off;hold on;
       plot(individual_mean_amp,'ok');
       title('peak(r)/mean(k)','fontweight','b');
       xlabel('sweep');ylabel(char(y_unit));
       
       subplot(2,3,6),
       %mean
       plot(peak_amp,'or');hold on;   
       plot(mean_amp,'ok');hold on;
       
       %median
       plot(peak_amp_med,'ob');hold on;   
       plot(mean_amp_med,'og');hold on
       title('peak(r/b)/mean(k/g)','fontweight','b');
       ylabel(char(y_unit));box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create structure for valuables created
analyzedData=struct('cell_ID',strcat('ny',int2str(cellID)));
[analyzedData(:).mode]=deal(rec_mode);
[analyzedData(:).traceNumber]=deal(traceNumber);
[analyzedData(:).time]=deal(time);
[analyzedData(:).subtracted_traces]=deal(traces);
[analyzedData(:).individual_peak_amp]=deal(individual_peak_amp);
[analyzedData(:).individual_mean_amp]=deal(individual_mean_amp);
%[analyzedData(:).Rs]=deal(Rs);
[analyzedData(:).Ihold]=deal(Ihold);
[analyzedData(:).mean_Trace]=deal(averageTrace);
[analyzedData(:).median_Trace]=deal(medianTrace);
%[analyzedData(:).mean_Rs]=deal(Rs_mean);
[analyzedData(:).mean_Ihold]=deal(Ihold_mean);

[analyzedData(:).peak_amp_time]=deal(peak_amp_time);
[analyzedData(:).peak_amp]=deal(peak_amp);
[analyzedData(:).rise_time]=deal(rise_time);
[analyzedData(:).peak_amp_time]=deal(peak_amp_time);
[analyzedData(:).peak_amp_time_10]=deal(peak_amp_time_10);
[analyzedData(:).peak_amp_time_90]=deal(peak_amp_time_90);


[analyzedData(:).peak_amp_time_median]=deal(peak_amp_time_med);
[analyzedData(:).peak_amp_median]=deal(peak_amp_med);
%[analyzedData(:).rise_time_median]=deal(rise_time_med);
[analyzedData(:).peak_amp_time_median]=deal(peak_amp_time_med);
%[analyzedData(:).peak_amp_time_10_median]=deal(peak_amp_time_10_med);
%[analyzedData(:).peak_amp_time_90_median]=deal(peak_amp_time_90_med);


[analyzedData(:).mean_amp]=deal(mean_amp);

assignin('base','SinglePulseData',analyzedData);

clear individual*

end


