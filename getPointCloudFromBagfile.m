function [lhd, rgba] = getPointCloudFromBagfile(path, sid, pid, dest)

while exist(dest,'file')
   choice = input(sprintf("%s already exists. Do you want to overwrite it? [Y/n]\n", filename), "s");
   if choice ~= 'y'
        dest = input("Enter a new name:\n", "s");
   else
       break;
   end
end

bag = rosbag(path).select('Topic', sid);
msgs = bag.readMessages;
lhd = [];
rgba = [];

for i=1:length(msgs)
    if ~mod(i, 1000)
        disp(i);
    end

    coord = [];
    color = [];
    lastCoord = 0;
    lastColor = 0;

    wip = msgs{i}.Whatispresent;
    coords = msgs{i}.Coordinate;
    colors = msgs{i}.Color;
    durs = msgs{i}.Duration;

    for j=1:length(durs)
        if char(wip(j)) == 'B'
            lastCoord = coords(j);
            lastColor = colors(j);
        elseif char(wip(j)) == 'C'
            lastColor = colors(j);
        else
            lastCoord = coords(j);
        end

        if (durs(j).Start <= pid && pid < durs(j).End) || (pid == durs(j).Start && pid == durs(j).End)
            coord = [
                    lastCoord.L
                    lastCoord.H
                    lastCoord.D
                ];
            color = [
                    lastColor.R
                    lastColor.G
                    lastColor.B
                    lastColor.A
                 ];
            break;
        end
    end
    lhd(i,:) = coord;
    rgba(i,:) = color;
end
fileID = fopen(dest,'w');
fprintf(fileID, 'ply\nformat ascii 1.0\nelement vertex %d\nproperty float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nproperty uchar alpha\nelement face 0\nproperty list uchar int vertex_indices\nend_header\n', length(msgs));
for i=1:length(lhd)
    fprintf(fileID,'%f %f %f %d %d %d %d\n', lhd(i,1), lhd(i,2), lhd(i,3), rgba(i,1), rgba(i,2), rgba(i,3), rgba(i,4));
end
fclose(fileID);
end

