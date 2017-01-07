
vocab_size = 2000;
files = dir(''.jpg');

train_idx = 0;
training_data = [];

for i=1:size(files)

    pfx = strcat('',files(i).name);
    I = imread(pfx) ;
    image(I) ;
    I = single(I) ; 
    [f,d] = vl_sift(I) ;
    
    train_idx = train_idx + 1;
    trainSet(train_idx).f = f;
    trainSet(train_idx).d = d;
    trainSet(train_idx).name = files(i).name;
    trainSet(train_idx).size = size(d,2);
    training_data = [training_data d];
    
    
end

files = dir(''.jpg');



for i=1:size(files)

    pfx = strcat('',files(i).name);
    I = imread(pfx) ;
    image(I) ;
    I = single(I) ;
    [f,d] = vl_sift(I) ;

    train_idx = train_idx + 1;
    trainSet(train_idx).f = f;
    trainSet(train_idx).d = d;
    trainSet(train_idx).name = files(i).name;
    trainSet(train_idx).size = size(d,2);
    training_data = [training_data d];    
    
end

% building the vocabulary using the descriptors of the training image
[C,A] = vl_ikmeans(training_data,vocab_size) ;

% building histogram of visual word for each training image
start_idx = 1;

for i=1:train_idx
    
    h_of_v = zeros(vocab_size,1);
    assignment = A( start_idx : start_idx + trainSet(i).size-1);
    start_idx = start_idx + trainSet(i).size;
    
    for j=1:vocab_size
        num = size(find(assignment == j),2);
        h_of_v(j,1) = num;
    end
    
    trainSet(i).h_vw = h_of_v;
    h_of_v;
end

% read the test image.
files = dir('test/*.jpg');

test_idx = 0;
test_data = [];

for i=1:size(files)

    pfx = strcat('test/',files(i).name);
    I = imread(pfx) ;
    image(I) ;
    I = single(I) ; % need any other conversion, or it is ok
    [f,d] = vl_sift(I) ;
    
    test_idx = test_idx + 1;
    testSet(test_idx).f = f;
    testSet(test_idx).d = d;
    testSet(test_idx).name = files(i).name;
    testSet(test_idx).size = size(d,2);
    test_data = [test_data d];
    
    
end

% compute the histogram of visual words for each test image

for i=1:test_idx
    
    d = testSet(i).d;
    d_size = testSet(i).size;    
    assignment = zeros(1, d_size);
    
    % build histogram of cluster assignments
    for j=1:d_size
        [assign, dist] = computeAssignment(double(C), double(d(:,j)));
        if (assign ~= -1)
            assignment(1,j) = assign;
        end
    end
    
    % build histogram of visual words
    h_of_v = zeros(vocab_size,1);
    start_idx = start_idx + size(testSet(i).d,2);    
    for j=1:vocab_size
        num = size(find(assignment == j),2);
        h_of_v(j,1) = num;
    end
    
    testSet(i).h_vw = h_of_v;
    h_of_v    
    
    
end


found_indices = zeros(1,test_idx);
for k=1:test_idx
ts_h_vw = testSet(k).h_vw;
dist = bitmax;
c=-1;
for i=1:train_idx


    tr_h_vw = trainSet(i).h_vw;

    chi_dist = 0;
    for j=1:vocab_size
        top = (tr_h_vw(j,1)-ts_h_vw(j,1))*(tr_h_vw(j,1)-ts_h_vw(j,1));
        bottom = (tr_h_vw(j,1)+ts_h_vw(j,1));

        if (bottom ~= 0)
            chi_dist = chi_dist + top/bottom;
        end
    end
    chi_dist;

    if (dist > chi_dist)
        dist = chi_dist;
        c = i;
    end

end

testSet(k).name
'matched to '
trainSet(c).name
found_indices(k) = c;
end


m=1;
mm=1;
matchedCount = 0;
for i=1:test_idx
    test_name = testSet(i).name;
    matched_name = trainSet(found_indices(i)).name;
    
    j = strfind(matched_name,'_');
    if (j > 1)
        prefix = matched_name(1:j(1)-1);
    end
    isFound =  findstr(test_name, prefix);
    
    if (~isempty(isFound))
        matchedCount = matchedCount + 1;
        matchedNames(m).test = test_name;
        matchedNames(m).match = matched_name;
        m = m + 1;
    else
        mismatchedNames(m).test = test_name;
        mismatchedNames(m).match = matched_name;
        
        mm = mm + 1;

    end
    
    
    
end

'total matched '
matchedCount
'percentage'
matchedCount/test_idx

