function [ c, dist ] = computeAssignment( C, d )


    dist = bitmax;
    c = -1;
    for i=1:size(C,2)        
        euclid_dist = norm(C(:,i)-d);
        if (dist > euclid_dist)
            dist = euclid_dist;
            c = i;
        end
    end

end

