function B = bigUnion(varargin)
% BIGUNION  n-ary union
%
%   B = BIGUNION(A1,A2,...,A2) calculates the union of the arrays A1, A2,
%   etc and returns the result in B. Each array can be of any type accepted
%   by the builtin UNION function, provided they are all of the same type.
    if isempty(varargin)
        B = [];
        
        return
    end

    B = varargin{1};
    
    for ii = 2:numel(varargin)
        B = union(B,varargin{ii});
    end
end