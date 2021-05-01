function [reconRealign, psfRealign] = TCSPCAlignmentv2(bckRcon, bckPSF, alnPos, ZeroPos, zOffset, sampleLength)
    % alnPos = 318;
    alnBase = 1024 - alnPos;
    temp = bckRcon(end:-1:1, :);
    reAlignData = temp(alnBase:end, :);

    temp = bckPSF(end:-1:1, :);
    reAlignPSF = temp(alnBase:end, :);

    firstRef = reAlignPSF(1:40, :);
    [~, alignIdx] = max(firstRef, [], 1);

    Width = size(bckRcon, 2);
    startIdxC = alignIdx;
    
    reAlignGraph = zeros(sampleLength, Width);
    reAlignPSFGraph = zeros(size(reAlignGraph));

    for i = 1:size(reAlignGraph, 2)
        curStartY = max(startIdxC(i) + zOffset, 1);
        curCol = reAlignData((curStartY:(min(curStartY + sampleLength - 1, 1024))), i);
        reAlignGraph(1:min(length(curCol), sampleLength), i) = curCol(:);

        curColPSF = reAlignPSF((curStartY:(min(curStartY + sampleLength - 1, 1024))), i);
        reAlignPSFGraph(1:min(length(curColPSF), sampleLength), i) = curColPSF(:);
    end


    cross1stRef = reAlignGraph;
    cross1stRef(1:ZeroPos, :) = 0;

    cross1stRefPSF = reAlignPSFGraph;
    cross1stRefPSF(1:ZeroPos, :) = 0;   

    reconRealign = cross1stRef;%permute(reshape(cross1stRef(1:128, :), [128, 32, 32]), [2, 3, 1]);
    psfRealign = cross1stRefPSF;%permute(reshape(cross1stRefPSF(1:128, :), [128, 32, 32]), [2, 3, 1]); 
    % realPSF = reshape(permute(nlosReshapeData, [3, 1, 2]), [128, 32 * 32]);

end	






