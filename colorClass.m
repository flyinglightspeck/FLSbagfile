classdef colorClass < handle
    properties
        red {mustBeNumeric} = -1
        green {mustBeNumeric} = -1
        blue {mustBeNumeric} = -1
        transparency {mustBeNumeric} = -1
    end
    methods
        function obj = colorClass(r, g, b, t)
            if nargin >= 3 
                obj.red = r;
                obj.green = g;
                obj.blue = b;
            end
            if nargin >= 4
                obj.transparency = t;
            end
        end
    end
end