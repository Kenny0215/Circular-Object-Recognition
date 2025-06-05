% function to use for filter out overlapping circles because it is too 
% clumped

function [fcenters, fradii] = filter_overlapping_circles(centers, radii)
    n = size(centers, 1);
    keep = true(n, 1);

    for i = 1:n
        if keep(i)
            x0 = centers(i, 1);
            y0 = centers(i, 2);
            r0 = radii(i);

            for j = i+1:n
                if keep(j)
                    xj = centers(j, 1);
                    yj = centers(j, 2);
                    rj = radii(j);

                    dist = sqrt((x0 - xj)^2 + (y0 - yj)^2);

                    % If circles overlap, remove the smaller one
                    if dist < (r0 + rj)
                        if r0 > rj
                            keep(j) = false;
                        else
                            keep(i) = false;
                            break;
                        end
                    end
                end
            end
        end
    end

    fcenters = centers(keep, :);
    fradii = radii(keep);
end