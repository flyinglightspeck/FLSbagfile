classdef msgElt < handle
    properties
        coordElt = 0
        colorsElt = 0
        dursElt = 0
        whatispresent = 'N' % N is for none, D for coordinate, C for color, B for both
        numPtClds {mustBeInteger} = 0
        FlightLog = {}
        NextBagElt = []
    end
    methods
        function output = setEndTS(obj,endTS)
            if endTS < obj.dursElt.startTS
                outputT= sprintf('Error in msgElt.setEndTS end of a duration %d is a value less than the start of the duration %d ', endTS, obj.dursElt.startTS);
                disp(outputT);
                error('Exiting, cannot continue.')
            end
            obj.dursElt.endTS = endTS;
        end
        function obj = msgElt(coordInstance, colorInstance, durationInstance)
            wp='N';
            if coordInstance ~= 0
                obj.coordElt = coordInstance;
                wp = 'D';
            end

            if colorInstance ~= 0
                obj.colorsElt = colorInstance;
                if wp == 'N'
                    wp = 'C';
                else
                    wp='B';
                end
            end
            obj.dursElt = durationInstance;
            obj.whatispresent = wp;
        end
    end
end