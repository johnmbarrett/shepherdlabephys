function [p,idx] = peak(A,dim,nanflag)
%PEAK    Absolutely largest component.
%   For vectors, PEAK(X) is the absolutely largest element in X, in other
%   words the element with the largest absolute value. For matrices,
%   PEAK(X) is a row vector containing the absolutely largest element from 
%   each column. For N-D arrays, PEAK(X) operates along the first
%   non-singleton dimension.
%
%   [Y,I] = PEAK(X) returns the indices of the absolutely largest values in
%   vector I. If the values along the first non-singleton dimension contain
%   more than one absolutely largest element, the index of the first one is
%   returned.
%
%   [Y,I] = PEAK(X,DIM) operates along the dimension DIM. 
%
%   PEAK is not recommended for use with complex numbers.
%
%   PEAK(..., NANFLAG) specifies how NaN (Not-A-Number) values are treated.
%   NANFLAG can be:
%   'omitnan'    - Ignores all NaN values and returns the absolutely 
%                  largest of the non-NaN elements.  If all elements are 
%                  NaN, then the first one is returned.
%   'includenan' - Returns NaN if there is any NaN value.  The index points
%                  to the first NaN element.
%   Default is 'omitnan'.
%
%   Example: If X = [2 -8 4; -7 3 -9] then 
%               peak(X,1) is [-7 8 -9],
%               peak(X,2) is [-8; -9] and 
%
%   See also MAX, MIN, CUMMAX, MEDIAN, MEAN, SORT.

%   Written by John Barrett 2017-08-09 14:37 CDT
%   Last updated John Barrett 2017-08-09 14:41 CDT

    if nargin < 2
        dim = find(size(A) > 1,1,'first');
        
        if isempty(dim)
            dim = 1;
        end
    end
    
    if nargin < 3
        nanflag = 'omitnan';
    end
    
    if verLessThan('matlab','2015a')
        [p,idx] = max(abs(A),[],dim);
    else
        [p,idx] = max(abs(A),[],dim,nanflag);
    end
    
    p = p.*sign(A(idx));
end