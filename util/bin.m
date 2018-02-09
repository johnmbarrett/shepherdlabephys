function C = bin(A,b,isOneDimensional)    
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