function rendBD = genSinglePSF(bdSize, xyDim, zResolution, laserPos, objctPos, normalization, sig)
	realSize = [xyDim,  xyDim, bdSize(3) * zResolution];
	patchNormal = [0, 0, -1]; 
	kc = 1;
	ks = 0;
%     centerPos = [xyDim / 2 xyDim / 2 0];
	rndSize = bdSize;
	rndRealSize = realSize;
	rendBD = forwardPSF2(rndSize, rndRealSize, laserPos, objctPos, patchNormal, kc, ks, normalization, sig);

	