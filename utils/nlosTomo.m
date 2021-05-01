classdef nlosTomo
    properties

    end

    methods
        function obj = nlosTomo(psfPath, noisePath, dataPath, ...
                              xyResolution, tResolution)
            obj.zResolution = tResolution * 3e8;

            obj.bckGndData = csvread(noisePath);
            obj.psfData = csvread(psfPath);
            obj.reconData = csvread(dataPath);

            obj.denoisedData = obj.reconData;
            obj.denoisedPsf = obj.psfData;


        end

        function plotGraph()
            figure; imshow(denoisedData);
            figure; imshow(denoisedPsf);


        function r = removeBadPt(obj, noiseShowY, threshold);
            % noiseShowY = 253:277;
            noiseRow = obj.psfData (noiseShowY, :);
            noiseRowSum = sum(noiseRow, 1);
            % threshold = 2000;

            obj.denoisedPsf


            sumThres = noiseRowSum>threshold;
            rmNoise(:, sumThres) = 0;
            rmNBck(:, sumThres) = 0;
            rmRnc(:, sumThres) = 0;
            if plotFlag
                figure; imshow(rmNoise / 200);
                figure; imshow(rmNBck / 200);
                figure; imshow(rmRnc / 200);
            end
        end

        function r = multiplyBy(obj,n)
            r = [o[bj.Value] * n;
        end
    end
end