%% Export a tiny FF network to nn_weights.h
fc1 = net.Layers(2);
fc2 = net.Layers(4);

W1 = fc1.Weights;
b1 = fc1.Bias;
W2 = fc2.Weights;
b2 = fc2.Bias;

fileID = fopen('nn_weights.h', 'w');

% Write constants
fprintf(fileID, '#define INPUT_SIZE %d\n', size(W1,2));
fprintf(fileID, '#define HIDDEN_SIZE %d\n', size(W1,1));
fprintf(fileID, '#define OUTPUT_SIZE %d\n\n', size(W2,1));

% Write W1
fprintf(fileID, 'const float W1[%d][%d] = {\n', size(W1,1), size(W1,2));
for i = 1:size(W1,1)
    fprintf(fileID, '  {');
    for j = 1:size(W1,2)
        if j < size(W1,2)
            fprintf(fileID, '%.6ff, ', W1(i,j));
        else
            fprintf(fileID, '%.6ff', W1(i,j));
        end
    end
    if i < size(W1,1)
        fprintf(fileID, '},\n');
    else
        fprintf(fileID, '}\n');
    end
end
fprintf(fileID, '};\n\n');

% Write b1
fprintf(fileID, 'const float b1[%d] = {', length(b1));
for i = 1:length(b1)
    if i < length(b1)
        fprintf(fileID, '%.6ff, ', b1(i));
    else
        fprintf(fileID, '%.6ff', b1(i));
    end
end
fprintf(fileID, '};\n\n');

% Write W2
fprintf(fileID, 'const float W2[%d][%d] = {\n', size(W2,1), size(W2,2));
for i = 1:size(W2,1)
    fprintf(fileID, '  {');
    for j = 1:size(W2,2)
        if j < size(W2,2)
            fprintf(fileID, '%.6ff, ', W2(i,j));
        else
            fprintf(fileID, '%.6ff', W2(i,j));
        end
    end
    if i < size(W2,1)
        fprintf(fileID, '},\n');
    else
        fprintf(fileID, '}\n');
    end
end
fprintf(fileID, '};\n\n');

% Write b2 safely
fprintf(fileID, 'const float b2[%d] = {', length(b2));
for i = 1:length(b2)
    if i < length(b2)
        fprintf(fileID, '%.6ff, ', b2(i));
    else
        fprintf(fileID, '%.6ff', b2(i));
    end
end
fprintf(fileID, '};\n');

fclose(fileID);
