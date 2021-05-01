constOffset = [0 0 0];
btchFile = 'ST';
saveBtchFile = 'ST1';
plotFlag = false;
testFlag = false; 

if testFlag
	mapPos = [0, 0, 0];
else
	lineRng = (-0.04:0.02:0.04) * 2;
	[X, Y, Z] = meshgrid(lineRng, lineRng, lineRng);
	mapPos = [Y(:), X(:), Z(:)];
end

load('resizeData/denoised.mat')

count = 1;
for i = 1:size(mapPos, 1);
	%% gen calibration psf
	% dataFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'data');
	% load(dataFileName, 'nlosReshapeData');
	psfFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'psf');
	load(psfFileName, 'nlosReshapePSF');
	rmPtFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'badPt');
	load(rmPtFileName, 'badPtMap');
	saveLength = 256;
	bdSize = [32, 32, 256];
	tRes = 55e-12;
	zResolution = tRes * 3e8;
	xyDim = 0.82;
	laserPos = [0.55, -0.16, 0];
	objctPos = [0.62, 0, 0.55] + mapPos(i, :) + constOffset;
	normalization = false;
	sig = 0.06;
	
	rendBD = genSinglePSF(bdSize, xyDim, zResolution, laserPos, objctPos, normalization, sig);
	rendBDVis = rendBD;
	rendBDVis(1:1, 1:2, 1:3) = max(rendBDVis(:));
	nlosReshapeDataVis = nlosReshapeData;
	nlosReshapeDataVis(1:1, 1:2, 1:3) = max(nlosReshapeDataVis(:));
	% figure; volshow(rendBDVis);
	% figure; volshow(nlosReshapeDataVis);
	realPSF = reshape(permute(nlosReshapePSF, [3, 1, 2]), [saveLength, 32 * 32]);
	reconData = reshape(permute(nlosReshapeData, [3, 1, 2]), [saveLength, 32 * 32]);
	simulatePSF = reshape(permute(rendBD, [3, 1, 2]), [saveLength, 32 * 32]);
	% figure;imshow(reconData / 1000); 
	simuNormFactor = 5;
	realNormFactor = 100;
	calibGraph = zeros([size(simulatePSF), 3]);
	calibGraph(:, :, 1) = simulatePSF / simuNormFactor ;
	calibGraph(:, :, 2) = realPSF/ realNormFactor;
	realPSFT = reshape(permute(nlosReshapePSF, [3, 2, 1]), [saveLength, 32 * 32]);
	reconDataT = reshape(permute(nlosReshapeData, [3, 2, 1]), [saveLength, 32 * 32]);
	simulatePSFT = reshape(permute(rendBD, [3, 2, 1]), [saveLength, 32 * 32]);
	calibGraphT = zeros([size(simulatePSFT), 3]);
	calibGraphT(:, :, 1) = simulatePSFT / simuNormFactor ;
	calibGraphT(:, :, 2) = realPSFT/ realNormFactor;
	if testFlag
	    figure; imshow(cat(1, calibGraph, calibGraphT));
	end
	%% Block visualization 
	visReshape = nlosReshapeData;
	visReshape(visReshape < 0) = 0;
	visReshape(1:1, 1:2, 1:3) = 100;
	if plotFlag
		figure; volshow(visReshape + rendBD * 100);
	end
	%% gen calibration psf
	neutralPsf = realPSF;
	neutralPsf(1:45, :) = 0;
	neutralPsf(120:end, :) = 0;
	[corelationMap, reMatchPSF, correctedData] = psfCalibration(simulatePSF, neutralPsf, reconData);
	if plotFlag
	    figure; imshow(reMatchPSF / 100);
	    figure; imshow(correctedData / 100);
	end
	nlosReshapeData = permute(reshape(correctedData, [saveLength, 32, 32]), [2, 3, 1]);
	[inPaintData] = badPtImPainting(badPtMap, nlosReshapeData);
	nlosReshapeDataVis = nlosReshapeData;
	inPaintDataVis = inPaintData;
	nlosReshapeDataVis(1:1, 1:2, 1:3) = 200;
	inPaintDataVis(1:1, 1:2, 1:3) = 200;
	if plotFlag
		figure; volshow(nlosReshapeDataVis);
		figure; volshow(inPaintDataVis);
	end
	inPaintDataR = inPaintData;
	dataFileName = sprintf('resizeData/%s_%s_calib_256_8142_%d.mat', saveBtchFile, 'data', count);
	disp(dataFileName);
	save(dataFileName, 'inPaintDataR')
	inPaintDataR(inPaintDataR < 0) = 0;
	inPaintDataR(1:1, 1:2, 1:3) = 200;
	if plotFlag
		figure; volshow(inPaintDataR);
	end
	finalRes = reshape(permute(inPaintDataR, [3, 1, 2]), [256, 32 * 32]);
	if plotFlag
		figure; imshow(finalRes / 1000);
	end
	count = count + 1;
	if ~testFlag
		close all;
	end
end















