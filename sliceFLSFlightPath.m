function [M] = sliceFLSFlightPath(path, sid, spid, epid, outputPath)

bag = rosbag(path).select('Topic', sid);
msgs = bag.readMessages;
M = [];

for i=1:length(msgs)
    lastCoord = 0;
    lastColor = 0;
    isClipStarted = false;

    wip = msgs{i}.Whatispresent;
    coords = msgs{i}.Coordinate;
    colors = msgs{i}.Color;
    durs = msgs{i}.Duration;

    newWip = [];
    newCoords = [];
    newColors = [];
    newDurs = [];

    for j=1:length(durs)
        if ~isClipStarted
            if char(wip(j)) == 'B'
                lastCoord = coords(j);
                lastColor = colors(j);
            elseif char(wip(j)) == 'C'
                lastColor = colors(j);
            else
                lastCoord = coords(j);
            end
    
            if durs(j).Start <= spid && spid < durs(j).End
                isClipStarted = true;
                
                newWip = [newWip cast('B', 'uint8')];
                newCoords = [newCoords lastCoord];
                newColors = [newColors lastColor];

                DurationMsg = rosmessage('flyinglightspeck/FLSDuration');

                if durs(j).Start <= epid && epid < durs(j).End
                    DurationMsg.Start = spid;
                    DurationMsg.End = epid;
                    newDurs = [newDurs DurationMsg];
                    break;
                else
                    DurationMsg.Start = spid;
                    DurationMsg.End = durs(j).End;
                    newDurs = [newDurs DurationMsg];
                end
            end
        else
            newWip = [newWip wip(j)];
            newCoords = [newCoords coords(j)];
            newColors = [newColors colors(j)];

            if durs(j).Start <= epid && epid < durs(j).End
                DurationMsg = rosmessage('flyinglightspeck/FLSDuration');
                DurationMsg.Start = durs(j).Start;
                DurationMsg.End = epid;
                newDurs = [newDurs DurationMsg];
                break;
            else
                newDurs = [newDurs durs(j)];
            end
        end
    end
    msg = rosmessage('flyinglightspeck/FLSElt');

    msg.Whatispresent = newWip;
    msg.Coordinate = newCoords;
    msg.Color = newColors;
    msg.Duration = newDurs;

    M = [M msg];
end

timeStamps = repelem([rostime("now")], length(M));
bagwriter = rosbagwriter(outputPath);
write(bagwriter,sid,timeStamps,M);

end

