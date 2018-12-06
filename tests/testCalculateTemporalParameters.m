function tests = testCalculateTemporalParameters
    tests = functiontests(localfunctions);
end

function testFlatResponse(testCase)
% Should give nothing
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters(zeros(10000,1),1e4);
    
    verifyTrue(testCase,isnan(peaks));
    verifyTrue(testCase,isnan(peakIndices));
    verifyTrue(testCase,isnan(latencies));
    verifyTrue(testCase,isnan(riseTimes));
    verifyTrue(testCase,isnan(fallTimes));
    verifyTrue(testCase,isnan(halfWidths));
    verifyTrue(testCase,isnan(peak10IndexRising));
    verifyTrue(testCase,isnan(peak90IndexRising));
    verifyTrue(testCase,isnan(peak90IndexFalling));
    verifyTrue(testCase,isnan(peak10IndexFalling));
    verifyTrue(testCase,isnan(peak50IndexRising));
    verifyTrue(testCase,isnan(peak50IndexFalling));
    verifyTrue(testCase,isnan(fallIntercept));
end

function testTriangleResponse(testCase)
% Simple test case
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([1:100 99:-1:1]',1e2);
    
    verifyEqual(testCase,peaks,100);
    verifyEqual(testCase,peakIndices,100);
    verifyEqual(testCase,latencies,0,'AbsTol',1e-6); % hard to be exact because it relies on polyfit
    verifyEqual(testCase,riseTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,fallTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,halfWidths,1);
    verifyEqual(testCase,peak10IndexRising,11); % plus one for all of these because we're using strict inequality
    verifyEqual(testCase,peak90IndexRising,91);
    verifyEqual(testCase,peak90IndexFalling,111);
    verifyEqual(testCase,peak10IndexFalling,191);
    verifyEqual(testCase,peak50IndexRising,51);
    verifyEqual(testCase,peak50IndexFalling,151);
    verifyEqual(testCase,fallIntercept,200,'AbsTol',1e-6);
end

function testDelayedTriangleResponse(testCase)
%Add a delay - should affect the indices and the latencies
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([zeros(1,100) 1:100 99:-1:1]',1e2);
    
    verifyEqual(testCase,peaks,100);
    verifyEqual(testCase,peakIndices,200);
    verifyEqual(testCase,latencies,1,'AbsTol',1e-6); % hard to be exact because it relies on polyfit
    verifyEqual(testCase,riseTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,fallTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,halfWidths,1);
    verifyEqual(testCase,peak10IndexRising,111); % plus one for all of these because we're using strict inequality
    verifyEqual(testCase,peak90IndexRising,191);
    verifyEqual(testCase,peak90IndexFalling,211);
    verifyEqual(testCase,peak10IndexFalling,291);
    verifyEqual(testCase,peak50IndexRising,151);
    verifyEqual(testCase,peak50IndexFalling,251);
    verifyEqual(testCase,fallIntercept,300,'AbsTol',1e-6);
end

function testDelayedTriangleResponseWithDelayedStart(testCase)
%Specify start - should affect the latencies but not the indices
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([zeros(1,100) 1:100 99:-1:1]',1e2,'Start',1.01);
    
    verifyEqual(testCase,peaks,100);
    verifyEqual(testCase,peakIndices,200);
    verifyEqual(testCase,latencies,0,'AbsTol',1e-6); % hard to be exact because it relies on polyfit
    verifyEqual(testCase,riseTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,fallTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,halfWidths,1);
    verifyEqual(testCase,peak10IndexRising,111); % plus one for all of these because we're using strict inequality
    verifyEqual(testCase,peak90IndexRising,191);
    verifyEqual(testCase,peak90IndexFalling,211);
    verifyEqual(testCase,peak10IndexFalling,291);
    verifyEqual(testCase,peak50IndexRising,151);
    verifyEqual(testCase,peak50IndexFalling,251);
    verifyEqual(testCase,fallIntercept,300,'AbsTol',1e-6);
end

function testDoubleTriangleResponse(testCase)
% Complex response that deliberately breaks the algorithm and gives the
% wrong answers
    [peaks,peakIndices,~,~,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([1:100 99:-1:0 1:200 199:-1:0]',1e2);
    
    verifyEqual(testCase,peaks,200);
    verifyEqual(testCase,peakIndices,400);
    % don't test latency and rise time, because the algorithm is guaranteed
    % to give the wrong answer
    verifyEqual(testCase,fallTimes,2,'AbsTol',1e-6); % this is right because we only look past the peak
    verifyEqual(testCase,halfWidths,2); % this is right because of strict inequality
    verifyEqual(testCase,peak10IndexRising,21); % the first triangle goes above 10% of peak
    verifyEqual(testCase,peak90IndexRising,381);
    verifyEqual(testCase,peak90IndexFalling,421);
    verifyEqual(testCase,peak10IndexFalling,581);
    verifyEqual(testCase,peak50IndexRising,301);
    verifyEqual(testCase,peak50IndexFalling,501);
    verifyEqual(testCase,fallIntercept,600,'AbsTol',1e-6);
end

function testDoubleTriangleResponseWithWindow(testCase)
% Add a window to ignore the second peak
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([1:100 99:-1:0 1:200 199:-1:0]',1e2,'Window',2);
    
    verifyEqual(testCase,peaks,100);
    verifyEqual(testCase,peakIndices,100);
    verifyEqual(testCase,latencies,0,'AbsTol',1e-6); % hard to be exact because it relies on polyfit
    verifyEqual(testCase,riseTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,fallTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,halfWidths,1);
    verifyEqual(testCase,peak10IndexRising,11); % /plus one for all of these because we're using strict inequality
    verifyEqual(testCase,peak90IndexRising,91);
    verifyEqual(testCase,peak90IndexFalling,111);
    verifyEqual(testCase,peak10IndexFalling,191);
    verifyEqual(testCase,peak50IndexRising,51);
    verifyEqual(testCase,peak50IndexFalling,151);
    verifyEqual(testCase,fallIntercept,200,'AbsTol',1e-6);
end

function testDelayedDoubleTriangleResponseWithWindow(testCase)
% Add a delay to test both the start and window parameters together
    [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = ...
        calculateTemporalParameters([zeros(1,100) 1:100 99:-1:0 1:200 199:-1:0]',1e2,'Start',1.01,'Window',2);
    
    verifyEqual(testCase,peaks,100);
    verifyEqual(testCase,peakIndices,200);
    verifyEqual(testCase,latencies,0,'AbsTol',1e-6); % hard to be exact because it relies on polyfit
    verifyEqual(testCase,riseTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,fallTimes,1,'AbsTol',1e-6);
    verifyEqual(testCase,halfWidths,1);
    verifyEqual(testCase,peak10IndexRising,111); % plus one for all of these because we're using strict inequality
    verifyEqual(testCase,peak90IndexRising,191);
    verifyEqual(testCase,peak90IndexFalling,211);
    verifyEqual(testCase,peak10IndexFalling,291);
    verifyEqual(testCase,peak50IndexRising,151);
    verifyEqual(testCase,peak50IndexFalling,251);
    verifyEqual(testCase,fallIntercept,300,'AbsTol',1e-6);
end