function [rows,cols] = subplots(k)
    rows = floor(sqrt(k));
    cols = ceil(sqrt(k));
    n = rows.*cols;
    cols(n < k) = cols(n < k) + 1;
end