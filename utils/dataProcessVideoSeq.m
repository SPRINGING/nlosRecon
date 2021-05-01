addpath('utils');

           
            
for dataNum = 1:5
    psfPath = sprintf('rawData/psf_10000ms_1f_1.mat');
    % reconDataPath = sprintf('rawData/histogram/S/Histogram1.csv');
    reconDataPath = sprintf('rawData/data_50ms_20f_%d.mat', dataNum);
    bgPSFPath = sprintf('rawData/noise_10000ms_1f_1.mat')
    % bgPath = sprintf('rawData/noise_100ms.mat');

    xyDim = 0.7;
    tRes = 55e-12;
    plotFlag = false;
    plotFlagFinal = false;
    dynScene = true;
    xyResolution =  xyDim / 32;
    zResolution  = tRes * 3e8;

    %% Reading in Data
    
    psfData = load(psfPath);
    % recon = csvread(reconDataPath);
    recon = load(reconDataPath);
    bckgndData = load(bgPSFPath);
    % bckgndDataNlos = load(bgPath);

    sampleLength = 256;

    dataPSF = psfData.allVideoData;
    dataRecon = recon.allVideoData;
    % dataRecon = recon;
    dataNoise = bckgndData.allVideoData;
    % nlosNoise = bckgndDataNlos.allVideoData;

    % vidSeqLength = 1%size(recon, 4);
    [Heigt, Width, Depth, dtLength] = size(dataRecon);
    vidSeq = zeros([Heigt, Width, sampleLength, dtLength]);

    dataDynRescaleVal = 20; 
    %% 删除下面一行百分号进行整个视频处理
    for j = 1:dtLength
        psf = dataPSF;
        recon = dataRecon;
        noise = dataNoise;
        psfData = zeros(Heigt, Width, Depth);
        bckgndData = zeros(Heigt, Width, Depth);

        for i = 1:size(psf, 4)
            psfData = psfData + psf(:, :, :, i);
            bckgndData = bckgndData + noise(:, :, :, i);
        end

        curFrame = recon(:, :, :, j);
        psfData = reshape(permute(psfData(end:-1:1, :, :), [3, 2, 1]), [Depth, Heigt * Width]);
        bckgndData = reshape(permute(bckgndData(end:-1:1, :, :), [3, 2, 1]), [Depth, Heigt * Width]);
        % nlosNoise = reshape(permute(nlosNoise(end:-1:1, :, :), [3, 2, 1]), [Depth, Heigt * Width]);
        reconData = reshape(permute(curFrame(end:-1:1, :, :), [3, 2, 1]), [Depth, Heigt * Width]);
        % 原始数据平铺
        if plotFlag
            figure; imshow(psfData / 500);
            figure; imshow(bckgndData / 500);
            figure; imshow(reconData / dataDynRescaleVal);
            % figure; imshow(nlosNoise / dataDynRescaleVal);
        end

        %% rm backGound Noise
        noiseShowY = 301:320;
        threshold = 2000;
        % 坏点移除, noiseShowY进行采样和时间上的叠加,当数值大于threshold,这个点就被算作坏点
        [rmRecon, rmPSF, rmNBck, badPtMap] = removeBadPt(reconData, psfData, bckgndData, noiseShowY, threshold);

        if plotFlag
            figure; imshow(rmPSF / 600);
            figure; imshow(rmNBck / 600);
            figure; imshow(rmRecon / dataDynRescaleVal);
        end 

        % 背景去除, rbConst是移除的轴向范围
        %% Remove Back Ground
        rbConst = 326;
        [bckRcon, bckPSF] = rmBackGnd(rmRecon, rmPSF, rmNBck * 1.5, rbConst);
        if dynScene
            bckRcon = rmRecon;
            % bckRcon(1:rbConst, :) = rmRecon(1:rbConst, :) - ;
        end
        bckRcon(bckRcon < 0) = 0;
        bckPSF(bckPSF < 0) = 0;

        if plotFlag
            figure; imshow(bckPSF / 600);
            figure; imshow(bckRcon / dataDynRescaleVal);
        end

        %% TCSPC Alignment, alnPos是对其算法的起始点, 选择一次反射的下沿 offset 和zeroPos现在的算法不需要了,被校准代替
        % 一次反射对齐
        alnPos = 364;
        zOffset = 0;
        ZeroPos = 30 - zOffset;
        
        [reconRealign, psfRealign] = TCSPCAlignmentv2(bckRcon, bckPSF, alnPos, ZeroPos, zOffset, sampleLength);
        normFactor = 100;


        if plotFlagFinal
            close all
            figure; imshow(psfRealign / normFactor);
            figure; imshow(reconRealign / dataDynRescaleVal);
            pause(0.1);
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
        %% 数据保存以及可视化
        saveLength = 256;
        saveFlag = false;
        btchFile = 'DynS/dynS';
        pinAmtVis = 1000;
        nlosReshapeData = permute(reshape(reconRealign(1:saveLength, :), [saveLength, 32, 32]), [2, 3, 1]);

        nlosReshapePSF = permute(reshape(psfRealign(1:saveLength, :), [saveLength, 32, 32]), [2, 3, 1]);

        % Block Visulization
        nlosReshapeData(nlosReshapeData < 0) = 0;
        nlosReshapePSF(nlosReshapePSF < 0) = 0;
        if plotFlag
            nlosReshapeDataVis = nlosReshapeData;
            nlosReshapePSFVis = nlosReshapePSF;
            nlosReshapeDataVis(1:1, 1:2, 1:3) = pinAmtVis/50;
            nlosReshapePSFVis(1:1, 1:2, 1:3) = pinAmtVis;
            figure; volshow(nlosReshapeDataVis);
            figure; volshow(nlosReshapePSFVis);
        end

        vidSeq(:, :, :, j) = nlosReshapeData;
        
        if saveFlag || j == 1
            dataFileName = sprintf('resizeData/%s%d_%s%d.mat', btchFile, dataNum, 'data', j);
            disp(dataFileName);
            save(dataFileName, 'nlosReshapeData');
            psfFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'psf');
            save(psfFileName, 'nlosReshapePSF');
            rmPtFileName = sprintf('resizeData/%s_%s.mat', btchFile, 'badPt');
            save(rmPtFileName, 'badPtMap');
        end
    end
    %% 

    dataFileName = sprintf('resizeData/%s_%s_VidSeq_%d.mat', btchFile, 'data', dataNum);
    disp(dataFileName);
    save(dataFileName, 'vidSeq');


    nlosReshapeData = vidSeq(:, :, :, 1);
    finalRes = reshape(permute(nlosReshapeData, [3, 1, 2]), [256, 32 * 32]);
    figure; imshow(finalRes);
end





