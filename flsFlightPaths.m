function [FLSArray] = flsFlightPaths(numPtClds, TravelPathArray, ColorChange, PtCldArray, silent)
FLSArray = {};
BagIdx = 0;

% Process the TravelPaths and ColorChanges to generate a bag file by:
% 1. Read point cloud i into a hash table HT
% 2. Enumerate entries in TravelPaths{i}
% 3. Probe HT with TravelPaths{i}.source.  If found then add
% TravelPaths{i}.destination to the hash table entry.  Add
% TravelPaths{i}.destination to the

% create a hash table on the first point cloud and populate it
hashMapOnFirstCldPt = containers.Map('KeyType','char', 'ValueType','any');
srcCloudPoint = PtCldArray{1};

% We use the backupVertexList because it is the original AND this code
% only reads coordinates of points without changing them.
for i=1:size( srcCloudPoint.backupVertexList, 2 )
    a1 = srcCloudPoint.backupVertexList(i);
    b1 = a1{1};
    hval=utilHashFunction(b1);
    % create a bag element and add it to the hash index
    coord1 = coordClass(b1(1), b1(2), b1(3));
    color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
    duration1 = durationClass(1);

    hashMapOnFirstCldPt(hval)=msgElt(coord1, color1, duration1);
end

hashMapArrays={};
hashMapArrays{1}=hashMapOnFirstCldPt;

% Enumerate the flight paths for each point cloud and probe the hash tables
% in reverse order
for ptcldidx=2:numPtClds
    outputT= ['Processing coordinate changes for point cloud ', num2str(ptcldidx-1), ' with ', num2str(size( TravelPathArray{ptcldidx-1}, 2)), ' flight paths.' ];
    disp(outputT);

    newHashMap = containers.Map('KeyType','char', 'ValueType','any');
    hashMapArrays{ptcldidx}=newHashMap;
    tgtTrvlPath = TravelPathArray(ptcldidx-1);

    % start time stamp for duration interval in milliseconds
    % startTS = (ptcldidx-1) * 1000/24;
    startTS = ptcldidx;

    % Enumerate the flight paths for change of position
    for k=1:size(tgtTrvlPath{1},2)
        b1=tgtTrvlPath{1}{k}{3};
        probeKey=utilHashFunction(b1);
        hashMapIdx=ptcldidx-1;
        foundProbeKey=false;
        for hidx=hashMapIdx:-1:1
            if foundProbeKey == false && hashMapArrays{hidx}.isKey(probeKey)
                % Close the interval for the current element
                tgtElt = hashMapArrays{hidx}(probeKey);
                tgtElt.dursElt.endTS = startTS;
                tgtElt.FlightLog = tgtTrvlPath{1}{k};

                % Put the destination in the new hash map
                b1=tgtTrvlPath{1}{k}{6};
                coord1 = coordClass(b1(1), b1(2), b1(3));
                color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
                duration1 = durationClass(startTS);
                hval=utilHashFunction(b1);

                % colors is zero because travel paths are
                myElt=msgElt(coord1, color1, duration1);
                if int8(tgtElt.colorsElt.red) == int8(color1.red) && int8(tgtElt.colorsElt.blue)== int8(color1.blue) && int8(tgtElt.colorsElt.green)==int8(color1.green) && int8(tgtElt.colorsElt.transparency)==int8(color1.transparency)
                    myElt.whatispresent='D';
                else
                    myElt.whatispresent='B';
                end

                newHashMap(hval)=myElt;

                foundProbeKey = true;
            end
        end
        if ~foundProbeKey
            outputT= sprintf('Error in storeFlightPathsInBagFile, flight path %d has no target FLS device.',k);
            disp(outputT);
            %error('Exiting, cannot continue.')
        end
    end

    tgtColorChg = ColorChange(ptcldidx-1);
    % Enumerate the change of colors
    for k=1:size(tgtColorChg{1},2)
        b1=tgtColorChg{1}{k}{3};
        probeKey=utilHashFunction(b1);
        hashMapIdx=ptcldidx-1;
        foundProbeKey=false;
        for hidx=hashMapIdx:-1:1
            if foundProbeKey == false && hashMapArrays{hidx}.isKey(probeKey)
                % Close the interval for the current element
                tgtElt = hashMapArrays{hidx}(probeKey);
                tgtElt.dursElt.endTS = startTS;
                tgtElt.FlightLog = tgtColorChg{1}{k};

                % Put the destination in the new hash map
                b1=tgtColorChg{1}{k}{6};
                coord1 = coordClass(b1(1), b1(2), b1(3));
                color1 = colorClass(b1(4), b1(5), b1(6), b1(7));
                duration1 = durationClass(startTS);
                hval=utilHashFunction(b1);
                if newHashMap.isKey(hval)
                    % Entry exists because it had a change of coordinate
                    tgtElt = hashMapArrays{hidx}(hval);
                    tgtElt.colorsElt=color1;
                    tgtElt.whatispresent='B';
                else
                    % maintain coord to generate bag file
                    myElt = msgElt(coord1, color1, duration1);
                    myElt.whatispresent='C';
                    newHashMap(hval)= myElt;
                end
                foundProbeKey = true;
            end
        end
        if ~foundProbeKey
            outputT= sprintf('Error in storeFlightPathsInBagFile, flight path %d has no target FLS device.',k);
            disp(outputT);
            error('Exiting, cannot continue.')
        end
    end
end

% endTS = numPtClds * 1000/24;
endTS = numPtClds;

% Enumerate entries and close their end intervals
for i=1:size(hashMapArrays, 2)
    tgtHash = hashMapArrays{i};
    ks = tgtHash.keys();
    for kidx=1:size(ks, 2)
        vl = tgtHash( ks{kidx} );
        if size(vl.FlightLog,1)==0
            % Close this entry, it is done.
            if vl.dursElt.endTS ~= -1
                outputT= sprintf('Error in storeFlightPathsInBagFile, endTS should be -1 for those entries with no flight paths in the first point cloud.');
                disp(outputT);
                error('Exiting, cannot continue.')
            else
                vl.dursElt.endTS = endTS;

                BagIdx = BagIdx+1;
                FLSArray{BagIdx}=vl;
            end
        else
            % Navigate the hash tables and populate the NextBagElt of each
            % entry
            if vl.dursElt.endTS == -1
                outputT= sprintf('Error in storeFlightPathsInBagFile, endTS should NOT be -1 for those entries with flight paths.');
                disp(outputT);
                error('Exiting, cannot continue.')
            else
                done = false;
                tgt_elt = vl;
                hidx=2;  % Index to the array of hash tables
                BagA2 = [];
                BagA2 = [BagA2, vl];
                while ~done
                    % Get the flight log
                    fl_log = tgt_elt.FlightLog;
                    if size(fl_log,1)==0
                        done = true;
                    else
                        b1=fl_log{6};
                        probeKey=utilHashFunction(b1);
                        if hashMapArrays{hidx}.isKey(probeKey)
                            tgt_elt = hashMapArrays{hidx}(probeKey);
                            if tgt_elt.dursElt.endTS == -1
                                tgt_elt.dursElt.endTS = endTS;
                                done = true;
                            else
                            end
                            BagA2 = [BagA2, tgt_elt];
                            remove(hashMapArrays{hidx}, probeKey);
                        end
                        hidx=hidx+1;
                    end
                end
                BagIdx = BagIdx+1;
                FLSArray{BagIdx}=BagA2;
            end
        end
    end
end

if ~silent
    % Total number of FLSs
    outputT= ['Success!  Computed paths for ', num2str(size(FLSArray,2)),' FLSs successfully.'];
    disp(outputT);

    myHistogram = [];
    minNumPaths=intmax;
    IdxMinPaths=-1;
    maxNumPaths=-1;
    IdxMaxPaths=-1;
    for i=1:size(FLSArray,2)
        sz = size(FLSArray{i}, 2);
        if sz > maxNumPaths
            maxNumPaths = sz;
            IdxMaxPaths = i;
        end
        if sz < minNumPaths
            minNumPaths = sz;
            IdxMinPaths = i;
        end

        try
            myHistogram(sz)=myHistogram(sz)+1;
        catch
            myHistogram(sz)=1;
        end
    end
    % FLS with minimum number of paths
    outputT= ['FLS ', num2str(IdxMinPaths) ,' has the fewest number of paths, ', num2str(minNumPaths),'.'];
    disp(outputT);

    % FLS with maximum number of paths
    outputT= ['FLS ', num2str(IdxMaxPaths) ,' has the most number of paths, ', num2str(maxNumPaths),'.'];
    disp(outputT);
    % Histogram of FLSs with different number of paths
    for i=1:size(myHistogram,2)
        outputT= ['Number of FLSs with ', num2str(i) ,' paths = ', num2str( myHistogram(i) ),''];
        disp(outputT);
    end
end

end