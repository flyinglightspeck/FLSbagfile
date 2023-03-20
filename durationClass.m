classdef durationClass < handle
    properties
        startTS {mustBeNumeric} = -1
        endTS {mustBeNumeric} = -1
    end
    methods
        function obj = durationClass(sTS, eTS)
            if nargin >= 1
                obj.startTS = sTS;
            end
            if nargin == 2
                obj.endTS = eTS;
            end
        end
    end
end