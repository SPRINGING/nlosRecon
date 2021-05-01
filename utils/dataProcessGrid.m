addpath('utils');


%% Constant Define
psfPath = sprintf('rawData/pt/Histogram1.csv');
reconDataPath = sprintf('rawData/static/Histogram1.csv');
bgPath = sprintf('rawData/noise/Histogram1.csv');
xyDim = 0.7;
tRes = 55e-12;
plotFlag = true;
xyResolution =  xyDim / 32;
zResolution  = tRes * 3e8;

%% Reading in Data

psfData = csvread(psfPath);
reconData = csvread(reconDataPath);
bckgndData = csvread(bgPath);


%% dim Rotation
tempHt_ = size(psfData, 1);

rotData = permute(reshape(reconData, [tempHt_, 32, 32]), [3, 2, 1]);
rotPsf = permute(reshape(psfData, [tempHt_, 32, 32]), [3, 2, 1]);
rotBckGnd = permute(reshape(bckgndData, [tempHt_, 32, 32]), [3, 2, 1]);

rotData   = rotData(end:-1:1, :, :);
rotPsf    = rotPsf(end:-1:1, :, :);
rotBckGnd = rotBckGnd(end:-1:1, :, :);

reconData = reshape(permute(rotData, [3, 1, 2]), [tempHt_, 32 * 32]);
psfData = reshape(permute(rotPsf, [3, 1, 2]), [tempHt_, 32 * 32]);
bckgndData = reshape(permute(rotBckGnd, [3, 1, 2]), [tempHt_, 32 * 32]);


%% Remove Bad Points
noiseShowY = 300:319;
threshold = 600;

[rmRecon, rmPSF, rmNBck, badPtMap] = removeBadPt(reconData, psfData, bckgndData, noiseShowY, threshold);

if plotFlag
    figure; imshow(rmRecon / 600);
    figure; imshow(rmPSF / 600);
    figure; imshow(rmNBck / 600);
end 

%% Remove Back Ground
rbConst = 330;
[bckRcon, bckPSF] = rmBackGnd(rmRecon, rmPSF, rmNBck, rbConst);

if plotFlag
    figure; imshow(bckPSF / 600);
    figure; imshow(bckRcon / 600);
end


%% TCSPC Alignment

alnPos = 365;
zOffset = 0;
ZeroPos = 30 - zOffset;
sampleLength = 256;
[reconRealign, psfRealign] = TCSPCAlignmentv2(bckRcon, bckPSF, alnPos, ZeroPos, zOffset, sampleLength);
normFactor = 100;

if plotFlag
    figure; imshow(reconRealign / normFactor);
    figure; imshow(psfRealign / normFactor);
end

clamp = 100;

rotDataVis = permute(reshape(reconRealign, [size(reconRealign, 1), 32, 32]), [2, 3, 1]);
rotPsfVis = permute(reshape(psfRealign, [size(psfRealign, 1), 32, 32]), [2, 3, 1]);

rotDataVis(rotDataVis < 0) = 0;
rotDataVis(rotDataVis > clamp) = clamp;
rotPsfVis(rotPsfVis > clamp) = clamp;
rotPsfVis(rotPsfVis < 0) = 0;

rotDataVis(1:1, 1:2, 1:3) = clamp;
rotPsfVis(1:1, 1:2, 1:3) = clamp;

if plotFlag
    figure; volshow(rotDataVis);
    figure; volshow(rotPsfVis);
end


%% Result Saving
saveLength = 256;
saveFlag = true;
btchFile = 'ST';
pinAmtVis = 1000;
nlosReshapeData = permute(reshape(reconRealign(1:saveLength, :), [saveLength, 32, 32]), [2, 3, 1]);
nlosReshapePSF = permute(reshape(psfRealign(1:saveLength, :), [saveLength, 32, 32]), [2, 3, 1]);

% Block Visulization
nlosReshapeData(nlosReshapeData < 0) = 0;
nlosReshapePSF(nlosReshapePSF < 0) = 0;
if plotFlag
    nlosReshapeDataVis = nlosReshapeData;
    nlosReshapePSFVis = nlosReshapePSF;
    nlosReshapeDataVis(1:1, 1:2, 1:3) = pinAmtVis;
    nlosReshapePSFVis(1:1, 1:2, 1:3) = pinAmtVis;
    figure; volshow(nlosReshapeDataVis);
    figure; volshow(nlosReshapePSFVis);
end

if saveFlag
    dataFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'data')
    save(dataFileName, 'nlosReshapeData');
    psfFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'psf')
    save(psfFileName, 'nlosReshapePSF');
    rmPtFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'badPt')
    save(rmPtFileName, 'badPtMap');
end

%% 




