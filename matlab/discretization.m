data = importdata('..\..\PedestrianData\CleanData\2--2018-08-7--11-36-33.txt');
[rows, columns] = size(data);

gaze_histogram = zeros(rows, 4);

for row = 1 : rows
    gaze_histogram(row, :) = [ data(row, 1), data(row, 5), data(row, 6), data(row, 7) ];
end

starts = zeros(rows,3);
ends = gaze_histogram(:,[2,3,4]);

arrow(starts, ends)