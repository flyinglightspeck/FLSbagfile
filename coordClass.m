classdef coordClass < handle
    properties
        length {mustBeNumeric} = -1
        height {mustBeNumeric} = -1
        depth {mustBeNumeric} = -1
    end
    methods
        function obj = coordClass(len, hgt, dpth)
            if nargin == 3
                obj.length = len;
                obj.height = hgt;
                obj.depth = dpth;
            end
        end
    end
end