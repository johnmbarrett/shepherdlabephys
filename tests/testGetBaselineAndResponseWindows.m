function tests = testGetBaselineAndResponseWindows
    tests = functiontests(localfunctions);
end

function testInvalidTime(testCase)
    timeParameters = {'BaselineStartTime' 'BaselineLength' 'ResponseStartTime' 'ResponseLength' 'Start' 'Window'};
    
    for ii = 1:numel(timeParameters)
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},'hello'),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},{1}),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},struct('time',1)),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},[]),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},1:4),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},Inf),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},NaN),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},1i),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},-1),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,timeParameters{ii},2),'MATLAB:InputParser:ArgumentFailedValidation');
    end
end

function testInvalidIndex(testCase)
    indexParameters = {'BaselineStartIndex' 'BaselineEndIndex' 'ResponseStartIndex' 'ResponseEndIndex'};
    
    for ii = 1:numel(indexParameters)
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},'hello'),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},{1}),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},struct('time',1)),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},[]),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},1:4),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},Inf),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},NaN),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},1i),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},0),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},0.5),'MATLAB:InputParser:ArgumentFailedValidation');
        verifyError(testCase,@() getBaselineAndResponseWindows(1,1,indexParameters{ii},2),'MATLAB:InputParser:ArgumentFailedValidation');
    end
end

function testStartAndWindow(testCase)
    n = 1e4;
    x = ones(n,1);
    
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'Start',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/2-1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'Window',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n/2+1 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'Start',0.5,'Window',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/2-1]);
end

function testStartTimeAndLength(testCase)
    n = 1e4;
    x = ones(n,1);
    
    % TODO : I'm not sure these all make sense, but at least the
    % documentation is clear on that point
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n n/2 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+2 n 1 n/2+1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.25,'BaselineLength',0.25);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseStartTime',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/2-1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.25,'ResponseStartTime',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n n/4 n/2-1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineLength',0.25,'ResponseStartTime',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/4+1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.25,'BaselineLength',0.25,'ResponseStartTime',0.5001);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n/2+1 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n/2+1 n/2 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineLength',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+2 n 1 n/2+1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.25,'BaselineLength',0.25,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseStartTime',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/2-1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.25,'ResponseStartTime',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n n/4 n/2-1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineLength',0.25,'ResponseStartTime',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n 1 n/4+1]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartTime',0.125,'BaselineLength',0.25,'ResponseStartTime',0.5,'ResponseLength',0.5);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2 n n/8 3*n/8]);
end

function testStartAndEndIndex(testCase)
    n = 1e4;
    x = ones(n,1);
    
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/2);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n n/2 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineEndIndex',n/2);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/4+1,'BaselineEndIndex',n/2);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4+1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseStartIndex',n/2+1);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/4+1,'ResponseStartIndex',n/2+1);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4+1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineEndIndex',n/4,'ResponseStartIndex',n/2+1);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/4]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/4+1,'BaselineEndIndex',n/2,'ResponseStartIndex',n/2+1);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4+1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseEndIndex',n/2);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n/2 1 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/2,'ResponseEndIndex',n/2);
    verifyEqual(testCase,[rsi rei bsi bei],[1 n/2 n/2 0]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineEndIndex',n/2,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/4+1,'BaselineEndIndex',n/2,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4+1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'ResponseStartIndex',n/2+1,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/4+1,'ResponseStartIndex',n/2+1,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/4+1 n/2]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineEndIndex',n/4,'ResponseStartIndex',n/2+1,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n 1 n/4]);
    [rsi,rei,bsi,bei] = getBaselineAndResponseWindows(x,n,'BaselineStartIndex',n/8+1,'BaselineEndIndex',3*n/8,'ResponseStartIndex',n/2+1,'ResponseEndIndex',n);
    verifyEqual(testCase,[rsi rei bsi bei],[n/2+1 n n/8+1 3*n/8]);
end

% TODO : test warnings, priority, overlapping