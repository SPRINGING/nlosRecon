function [reAlignR, reAlignGraph, cross1stRef] = alignTCSPCHelper(toRealign, alnPos, ZeroPos, zOffset, sampleLength)
    % alnPos = 318;
    alnBase = 1024 - alnPos;
    temp = toRealign(end:-1:1, :);
    reAlignR = temp(alnBase:end, :);
    saveFlag = true;
    firstRef = reAlignR(1:40, :);
    [~, alignIdx] = max(firstRef, [], 1);
    % 
    Width = size(toRealign, 2);
    startIdxC = alignIdx;
    reAlignGraph = zeros(sampleLength, Width);
    for i = 1:size(reAlignGraph, 2)
        curStartY = max(startIdxC(i) + zOffset, 1);
        curCol = reAlignR((curStartY:(min(curStartY + sampleLength - 1, 1024))), i);
        reAlignGraph(1:min(length(curCol), sampleLength), i) = curCol(:);
    end
    cross1stRef = reAlignGraph;
    cross1stRef(1:ZeroPos, :) = 0;
    nlosReshapeData = permute(reshape(cross1stRef(1:128, :), [128, 32, 32]), [2, 3, 1]);
    realPSF = reshape(permute(nlosReshapeData, [3, 1, 2]), [128, 32 * 32]);

end


