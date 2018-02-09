function C = bin(A,b,isOneDimensional)    
%BIN    Bin a matrix by averaging blocks of pixels
%
% C = BIN(A,b) bins the M_1 x M_2 x ... x M_n matrix A into a new M_1/b x
% M_2/b x ... x M_n/b matrix C by taking the average value of each b x b
% ... x b block of A and assigning the result to the corresponding element 
% in C.  The behaviour of BIN is undefined and likely version-dependent if 
% b does not exactly divide the size of any dimension of A.
%
% C = BIN(A,b,ISONEDIMENSIONAL) performs one-dimensional binning along each
% column of A is ISONEDIMENSIONAL is set to true, otherwise it acts exactly
% as the two-argument version of BIN.

    if nargin < 3
        isOneDimensional = false;
    end
    
    if isOneDimensional && isvector(A)
        A = A(:);
    end
    
    sizeA = size(A);
    C = zeros([sizeA(1:(2-isOneDimensional))/b sizeA((3-isOneDimensional):end)]);
    n = b^(2-isOneDimensional);
    
    if ndims(A) <= 2
        nFrames = 1;
    else
        nFrames = prod(sizeA(3:end));
    end
    
    c = (b-(b-1)*isOneDimensional);
    
    for kk = 1:nFrames
        for ii = 1:b
            for jj = 1:c
                C(:,:,kk) = C(:,:,kk) + double(A(ii:b:end,jj:c:end,kk))/n;
            end
        end
    end
end