classdef Map < handle
%MAP    A class representing a map of data
%
% A MAP is a container for data that should be displayed in a particular
% pattern.  Internally, it stores an array of data (that may be of any
% type) and a pattern specifying how that data should be mapped into a 2D
% grid.
%
% MAP contains the following public properties:
%
%   'Array'     The Data arranged according to the map.  The first two
%               dimensions will have the same size as the Pattern, while
%               the N+1th remaining dimension will have the same size as
%               the Nth data dimension.
%   'Data'      The raw data.  May be of any type.  The size of the first 
%               dimension determines the number of elements in the Pattern.
%   'Pattern'   A matrix of indicies indicating which elements (or rows, or
%               slices, etc.) of Data belong in each grid position in the
%               map.  Must have the same number of elements as the first
%               dimension of Data.  Replacing Data with data of a different
%               size erases the pattern.

% Created by John Barrett 2017-08-24 12:28 CDT
% Last modified by John Barrett 2017-08-24 12:29 CDT
    properties(Dependent=true)
        Array       % The data arranged according to the map.  The first two dimensions will have the same size as the pattern, while the N+1th remaining dimension will have the same size as the Nth data dimension.    
        Data        % The raw data.  May be of any type.  The size of the first dimension determines the number of elements in the pattern.
        Pattern     % A matrix of indicies indicating which elements (or rows, or slices, etc.) of Data belong in each grid position in the map.  Must have the same number of elements as the first dimension of Data.  Replacing Data with data of a different size erases the pattern.
    end
    
    properties(Access=protected,Hidden=true)
        Colons
        Data_
        Pattern_
    end
    
    methods
        function self = Map(data,pattern)
        %MAP    Constructor for mapAnalysis.Map
        %
        % MAP(DATA,PATTERN) constructs a MAP of DATA with the specified
        % PATTERN
            self.Data = data;
            self.Pattern = pattern;
        end
        
        function array = get.Array(self)
            array = self.Data_(self.Pattern(:),self.Colons{:});
            sizeData = size(self.Data_);
            array = reshape(array,[size(self.Pattern) sizeData(2:end)]);
        end
        
        function set.Array(self,array)
            self.Data(self.Pattern(:),self.Colons{:}) = reshape(array,size(self.Data_));
        end
        
        % the basic Map puts very little constaints on its data, but I
        % thought it best to create getters and setters so subclasses can
        % add their own validation
        function data = get.Data(self)
            data = self.Data_;
        end
        
        function set.Data(self,data)
            if ~isempty(self.Pattern)
                mapDim = find(size(data) == numel(self.Pattern));
                
                if isempty(mapDim)
                    % erase the pattern if changing the size of the map
                    self.Pattern_ = [];
                else
                    % keep the map in the first dimension
                    data = permute(data,[mapDim setdiff(1:ndims(data),mapDim)]);
                end
            end
                
            self.Data_ = data;
            self.Colons = repmat({':'},1,ndims(data)-1);
        end
        
        function pattern = get.Pattern(self)
            pattern = self.Pattern_;
        end
        
        function set.Pattern(self,pattern)
            assert(ismatrix(pattern) && isnumeric(pattern) && isequal(sort(pattern(:))',1:size(self.Data_,1)),'ShepherdLab:mapAnalysis:Map:InvalidPattern','Pattern must be a matrix of indices, one for every row of data');
            
            self.Pattern_ = pattern;
        end
    end
    
    methods(Access=public,Sealed=true)
        function map = derive(self,fun)
        %DERIVE Derive a new map by applying a function
        %
        % NEWMAP = DERIVE(OLDMAP,FUN) creates a new map NEWMAP by applying 
        % FUN to the data in OLDMAP.  The resulting map will have the same
        % pattern as the old one, hence the size(X,1) == size(FUN(X),1)
        % must be true for all X.
            map = mapAnalysis.Map(fun(self.Data),self.Pattern);
        end
    end
end