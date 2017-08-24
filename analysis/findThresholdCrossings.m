function [crossingIndices,crossingValues,crossingPolarities] = findThresholdCrossings(data,threshold,polarity,dim)
%FINDTHRESHOLDCROSSINGS    Finds points where a vector crosses a threshold
%
% IDX = FINDTHRESHOLDCROSSINGS(DATA,THRESHOLD) returns a list of indices
% IDX where the values in DATA rise above the THRESHOLD.  If DATA is a
% vector, IDX is also a vector. If DATA is an array, FINDTHRESHOLDCROSSINGS
% searches along each column of DATA in turn and returns the result as a
% cell array. THRESHOLD may be a scalar or, if DATA is an array, an array
% with the same dimensionality as DATA except the first dimension has size
% 1.
%
% IDX = FINDTHRESHOLDCROSSINGS(DATA,THRESHOLD,POLARITY) specifies which
% direction of threshold crossing to search for.  If POLARITY is 1,
% 'positive', 'rising', or 'up', rising thresholds are searched for.  If
% POLARITY is -1, 'negative', 'falling', or 'down', falling thresholds are
% searched for.  If POLARITY is 0, 'bipolar', 'bidirectional', or 'both',
% FINDTHRESHOLDCROSSINGS searches in both directions.  In this case,
% THRESHOLD must be a two-element vector or an array with first dimension
% 1, second through penultimate dimensions equal to the corresponding
% dimensions in DATA, and last dimension of size 2.  The first element (or
% hyper*plane in the array case) specifies the positive threshold and the
% second the negative threshold.
%
% IDX = FINDTHRESHOLDCROSSINGS(DATA,THRESHOLD,POLARITY,DIM) specifies which
% dimension to search along.  By default FINDTHRESHOLDCROSSINGS assumes the
% first non-singleton dimension.  If you use this option and threshold is
% an array, the DIMth dimension of THRESHOLD must have size 1 and the
% remainder must match the size of the corresponding dimension in DATA
% (plus an extra dimension of size 2 in the bipolar case).
%
% [IDX,VAL,POL] = FINDTHRESHOLDCROSSINGS(...) also returns the values at
% and polarity of each threshold crossing.

    if nargin < 3
        polarity = 1;
    end
    
    if isnumeric(polarity)
        assert(isscalar(polarity) && ismember(polarity,[-1 0 1]),'ShepherdLab:findThresholdCrossing:InvalidPolarity','Polarity must be one of the following values: -1, ''negative'', ''falling'', ''down'', 0, ''bipolar'', ''bidirectional'', ''both'', 1, ''positive'', ''rising'', ''up''');
    elseif ischar(polarity)
        assert(ismember(polarity,{'positive' 'rising' 'up' 'negative' 'falling' 'down' 'bipolar' 'bidirectional' 'both'}),'ShepherdLab:findThresholdCrossing:InvalidPolarity','Polarity must be one of the following values: -1, ''negative'', ''falling'', ''down'', 0, ''bipolar'', ''bidirectional'', ''both'', 1, ''positive'', ''rising'', ''up''');
        
        switch polarity(1)
            case {'p' 'r' 'u'}
                polarity = 1;
            case {'n' 'f' 'd'}
                polarity = -1;
            case 'b'
                polarity = 0;
        end
    else
        error('ShepherdLab:findThresholdCrossing:InvalidPolarity','Polarity must be one of the following values: -1, ''negative'', ''falling'', ''down'', 0, ''bipolar'', ''bidirectional'', ''both'', 1, ''positive'', ''rising'', ''up''');
    end
    
    nThresholds = 2-abs(polarity);
    
    if isvector(data)
        assert(numel(threshold) == nThresholds,'ShepherdLab:findThresholdCrossings:InvalidThresholdSize','When the data is a vector, threshold must be a scalar for positive or negative thresholds or a two-element vector for bipolar thresholds');
        
        [crossingIndices,crossingValues,crossingPolarities] = findThresholdCrossingsVector(data,threshold,polarity);
        return
    end
    
    if nargin < 4
        dim = find(size(data) > 1,1);
    else
        % TODO : fully test this.  I should really do unit testing at some point
        warning('ShepherdLab:findThresholdCrossings:DimArgument','The dim argument to this function is not fully tested.  Use at your own risk.');
    end
    
    if isempty(dim) || ~isnumeric(dim) || ~isscalar(dim) || dim < 1 || dim > ndims(data)
        dim = 1;
    end
    
    otherDims = setdiff(1:ndims(data),dim);
    
    data = permute(data,[dim otherDims]);
    
    sizeData = size(data);
    
    if numel(threshold) == nThresholds
        threshold = repmat(reshape(threshold,[ones(1,ndims(data)) nThresholds]),[1 sizeData(2:end) 1]);
    else
        threshold = permute(threshold,[dim setdiff(1:(ndims(data)+(polarity==0)),dim)]);

        sizeThreshold = size(threshold);

        assert(sizeThreshold(1) == 1,'ShepherdLab:findThresholdCrossings:InvalidThresholdSize','size(threshold,dim) must equal 1');

        % TODO : might be good for the bipolar option to also put the
        % thresholds along the search dimension
        assert(isequal(sizeThreshold(2:(end-(polarity==0))),sizeData(2:end)) && (polarity ~= 0 || sizeThreshold(end) == 2),'ShepherdLab:findThresholdCrossings:InvalidThresholdSize','Each dimension of threshold must have the same size as the corresponding dimension of the data, except for the dimension being search along and if the polarity is bipolar then threshold must have an extra dimension of size 2.')
    end
    
    dimDists = arrayfun(@(n) ones(n,1),sizeData(2:end),'UniformOutput',false);
    
    if polarity == 0
        threshold = permute(threshold,[ndims(threshold) 2:(ndims(threshold)-1) 1]);
    end
    
    data = mat2cell(data,sizeData(1),dimDists{:});
    
    threshold = mat2cell(threshold,1+(polarity==0),dimDists{:});
    
    [crossingIndices,crossingValues,crossingPolarities] = cellfun(@(d,t) findThresholdCrossingsVector(d,t,polarity),data,threshold,'UniformOutput',false);
end

function [crossingIndices,crossingValues,crossingPolarities] = findThresholdCrossingsVector(data,threshold,polarity)
    if polarity > -1
        positiveCrossings = find(diff(data >= threshold(1)) == 1)+1;
    else
        positiveCrossings = [];
    end
    
    if polarity < 1
        negativeCrossings = find(diff(data <= threshold(2+polarity)) == 1)+1;
    else
        negativeCrossings = [];
    end
    
    [crossingIndices,sortIndices] = sort([positiveCrossings;negativeCrossings]);
    crossingValues = data(crossingIndices);
    crossingPolarities = [ones(numel(positiveCrossings),1); -1*ones(numel(negativeCrossings),1)];
    crossingPolarities = crossingPolarities(sortIndices);
end
