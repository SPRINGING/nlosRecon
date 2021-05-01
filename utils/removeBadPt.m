function [rmRecon, rmPSF, rmNBck, badPtMap] = removeBadPt(reconData, psfData, bckGndData, noiseShowY, threshold);
    noiseRow = bckGndData(noiseShowY, :);
    noiseRowSum = sum(noiseRow, 1);
    sumThres = noiseRowSum>threshold;
    
    rmNBck = bckGndData;
    rmPSF = psfData;
    rmRecon = reconData;

    rmNBck(:, sumThres) = 0;
    rmPSF(:, sumThres) = 0;
    rmRecon(:, sumThres) = 0;

    badPtMap = sumThres;
end