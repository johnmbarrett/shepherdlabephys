function B = pagefun(fun,A,dims,varargin)
    if nargin < 2
        error('ShepherdLab:pagefun:MissingArguments','You must supply a function and a matrix for it to operate on.');
    end
    
    if ~isa(fun,'function_handle')
        error('ShepherdLab:pagefun:InvalidArgument','First argument to pagefun must be a function handle');
    end
    
    if ismatrix(A)
        B = fun(A,varargin{:});
        return
    end
    
    sizeA = size(A);
    
    if nargin < 3
        dims = [1 2];
    elseif ~isnumeric(dims) || ~isequal(size(dims),[1 2]) || any(isnan(dims(:)) | dims(:) < 1 | dims(:) > ndims(A))
        varargin = [{dims} varargin];
        dims = [1 2];
    end
    
    otherDims = setdiff(1:ndims(A),dims);
    
    A = permute(A,[dims otherDims]);
    
    n = prod(sizeA(otherDims));
    
    B = zeros(size(A));
    
    for ii = 1:n
        B(:,:,ii) = fun(A(:,:,ii),varargin{:});
    end
    
    B = ipermute(B,[dims otherDims]);
end