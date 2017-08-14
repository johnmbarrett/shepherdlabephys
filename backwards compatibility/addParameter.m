function addParameter(parser,varargin)
    if verLessThan('matlab','2013b')
        parser.addParamValue(varargin{:});
    else
        parser.addParameter(varargin{:});
    end
end