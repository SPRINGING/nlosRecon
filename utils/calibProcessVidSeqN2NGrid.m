
btchFile = 'Dyn';
saveBtchFile = 'STD6Vid';
plotFlag = true;
testFlag = false; 
plotFlag2 = false;

% anchorPos = [0   -0.0400    0.0400];
vidSeqLength = 200;
count = 1;

% dataFileName = sprintf('resizeData/denoised.mat');
% load(dataFileName, 'denoise');
% processData = denoise(1, :, :, :, :);

% processData = videoDataCut(:, :, :, 1);

if testFlag
	mapPos = [0, 0, 0];
else
	lineRng = (-0.04:0.02:0.04) * 2;
	[X, Y, Z] = meshgrid(lineRng, lineRng, lineRng);
	mapPos = [Y(:), X(:), Z(:)];
end

for i = 1:size(mapPos, 1)
	anchorPos = mapPos(i, :);
	%% gen calibration psf
	% nlosReshapeData = squeeze(processData);
	dataFileName = sprintf('resizeData/%s_%s1.mat', btchFile, 'data');
	load(dataFileName, 'nlosReshapeData');
	psfFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'psf');
	load(psfFileName, 'nlosReshapePSF');
	rmPtFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'badPt');
	load(rmPtFileName, 'badPtMap');


	nlosReshapeData = permute(nlosReshapeData, [2, 1, 3]);
	nlosReshapePSF = permute(nlosReshapePSF, [2, 1, 3]);
	badPtMap = permute(reshape(badPtMap, [32, 32]), [2, 1]);
	
	nlosReshapeData = nlosReshapeData(end:-1:1, :, :);
	nlosReshapePSF = nlosReshapePSF( end:-1:1, :, :);
	badPtMap = badPtMap(end:-1:1, :, :);


	saveLength = 256;
	bdSize = [32, 32, 256];
	tRes = 55e-12;
	zResolution = tRes * 3e8;
	xyDim = 0.82;
	laserPos = [0.55, -0.16, 0];
	objctPos = [0.60, 0.0, 0.46] + anchorPos;
	normalization = false;
	sig = 0.05;
	
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

	finalRes = reshape(permute(nlosReshapeData, [3, 1, 2]), [256, 32 * 32]);

	% if testFlag
	%     figure; imshow(finalRes / 20);
	%     pause(0.3)
	% end

	if testFlag
		figure; imshow(cat(1, calibGraph, calibGraphT));
		% figure; imshow()
		figure;imshow(reconData / 10); 
		pause(0.3)
	end



	%% Block visualization 
	visReshape = nlosReshapeData;
	visReshape(visReshape < 0) = 0;
	visReshape(1:1, 1:2, 1:3) = 100;
	if plotFlag2
		figure; volshow(visReshape + rendBD * 100);
	end
	%% gen calibration psf
	neutralPsf = realPSF;
	neutralPsf(1:45, :) = 0;
	neutralPsf(120:end, :) = 0;
	[corelationMap, reMatchPSF, correctedData] = psfCalibration(simulatePSF, neutralPsf, reconData);
	if plotFlag2
	    figure; imshow(reMatchPSF / 100);
	    figure; imshow(correctedData / 100);
	end
	nlosReshapeData = permute(reshape(correctedData, [saveLength, 32, 32]), [2, 3, 1]);
	[inPaintData] = badPtImPainting(badPtMap, nlosReshapeData);
	nlosReshapeDataVis = nlosReshapeData;
	inPaintDataVis = inPaintData;
	nlosReshapeDataVis(1:1, 1:2, 1:3) = 200;
	inPaintDataVis(1:1, 1:2, 1:3) = 200;
	if plotFlag2
		figure; volshow(nlosReshapeDataVis);
		figure; volshow(inPaintDataVis);
	end
	inPaintDataR = inPaintData;
	dataFileName = sprintf('resizeData/%s_%s_calib_256_8142_%d.mat', saveBtchFile, 'data', i);
	disp(dataFileName);
	save(dataFileName, 'inPaintDataR')
	inPaintDataR(inPaintDataR < 0) = 0;
	inPaintDataR(1:1, 1:2, 1:3) = 200;
	if plotFlag2
		figure; volshow(inPaintDataR);
	end
	finalRes = reshape(permute(inPaintDataR, [3, 1, 2]), [256, 32 * 32]);
	if ~testFlag && plotFlag
		figure; imshow(finalRes/10);
		pause(0.5);
	end
	count = count + 1;
	if ~testFlag
		close all;
	end
end











