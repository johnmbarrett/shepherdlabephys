function output = singlePulse_stimulation_analysis3(individual_traces, time, sr, RsStart)

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
stim_onset     = 0.2;   %in second
analysis_width = 0.05;          %in second
% sr             = 10000;         %sampling rate
voltage_stp    = -5;            %in mV
stp_duration   = 0.05;          %in second
%==========================================================================

w_1 = stim_onset*sr; %stim onset into sampling points
w_2 = (stim_onset+analysis_width)*sr ;%end smapling point of analysis window
x_range = w_2-w_1+1;
%==========================================================================
traceNumber = size(individual_traces,2);

[averageTrace_filtered,averageTrace,~,traces,Ihold] = preprocess(individual_traces,sr,'Start',stim_onset-1/sr,'FilterFun',@mean,'FilterLength',5);

Ihold_mean = nanmean(Ihold);%mean holding current

%==========================================================================
%calculation from averaged trace (mean and peak (E/IPSC/P)

%mean trace=========
mean_amp = nanmean(averageTrace(w_1:w_2,:)); %mean amp from mean trace
[peak_amp,peak_amp_index,~,~,~,~,peak_amp_index_10,peak_amp_index_90] = calculateTemporalParameters(averageTrace_filtered,sr,'Start',stim_onset,'Window',analysis_width);

%median trace=========
medianTrace = nanmedian(traces,2);
mean_amp_med = nanmean(medianTrace(w_1:w_2,:)); %mean amp from median trace
[peak_amp_med,peak_amp_index_med] = peak(medianTrace(w_1:w_2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculation from individual traces (mean and peak E/IPSC/P)
individual_mean_amp = nanmean(traces(w_1:w_2,:));
individual_peak_amp = peak(traces(w_1:w_2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rs calculation

Rs = calculateSeriesResistance(traces,sr,'Start',RsStart,'Window',stp_duration,'VoltageStep',voltage_stp);
Rs_mean = nanmean(Rs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculation of peak time and rise time (10-90% peak)

%median trace
peak_amp_time_med = time(peak_amp_index_med);

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
       plot(time(peak_amp_index_10), averageTrace_filtered(peak_amp_index_10),'ob','markersize',8);hold on;
       plot(time(peak_amp_index_90), averageTrace_filtered(peak_amp_index_90),'ob','markersize',8);hold on;
       plot(time(peak_amp_index), peak_amp,'ob','markersize',8);
       
       %median 
      % plot(time,medianTrace,'r');hold on
      % plot(peak_amp_time_10_med, peak_amp_10_med,'og','markersize',8);hold on;
      % plot(peak_amp_time_90_med, peak_amp_90_med,'og','markersize',8);hold on;
      % plot(peak_amp_time_med, peak_amp_med,'og','markersize',8);
       
       title('mean/median trace','fontweight','b');
       xlabel('ms');ylabel(char(y_unit));
       vline(w_1/10,'k:');hold on;vline(w_2/10,'k:');box off
       
       
       
       subplot(2,3,4),
      plot(Rs,'ok');
      title('series','fontweight','b');
      xlabel('sweep');ylabel('M{\Omega}');box off
       
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
return
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


