clear;
close all;

longCompFlag = false;
normFlag = false;
tResolution = 55e-12;
C = 3e8;
zResolution = tResolution * C ;
psfDim = 16;

bdSize = [32, 32, 256];  % body Size in Index
xyDim = 0.82;
realSize = [xyDim, xyDim, bdSize(3) * zResolution];    % render Size in Actual Dimension
normalization = false;
psfSize = [psfDim, psfDim, psfDim];

psf = sparse(prod(bdSize), prod(psfSize));

laserPos = [0.5, -0.15, 0];
patchNormal = [0, 0, -1]; % laser Normal

kc = 1;
ks = 0;
lasDt =250e-12; %laser pulse time

centerPos = [xyDim / 2 xyDim / 2 0];
offsets =  0 - centerPos;

% [Y, X, Z] = ndgrid( linspace(-0.1, 1.1, psfDim), ...
%                     linspace(-0.7, 0.5, psfDim), ...
%                     linspace(0.1, 1.1, psfDim * 4));
[Y, X, Z] = ndgrid( linspace(-0.1, 1.1, psfDim), ...
                    linspace(-0.6, 0.6, psfDim), ...
                    linspace(0.1, 1.1, psfDim * 4));
                
allPos = [Y(:), X(:), Z(:)];
disp('allPos');
disp(size(allPos));
disp('laserPos:')
disp(laserPos);
disp('realSize:')
disp(realSize);
posMat = [];
for i = 1:length(allPos)
    posMat(i, :) = allPos(i, :);
end
figure;scatter3(posMat(:, 1), posMat(:, 2), posMat(:, 3), 'r.');
axis equal
drawnow();



sig = 0.03;
for i = 1:100
fprintf('.')
end
fprintf('\n')

psfPrintLen = round(prod(psfSize) / 100);
allpsf = sparse(prod(bdSize), prod(psfSize));
rndSize = bdSize;
rndRealSize = realSize;
if longCompFlag
    rndSize(3) = bdSize(3) * 2;
    rndRealSize(3) = rndRealSize(3) * 2;
end


parfor count = 1:length(allPos)
    objctPos = allPos(count, :);
    % nlos = forwardPSF2(rndSize, rndRealSize, laserPos, objctPos, patchNormal, kc, ks, normalization, sig);
    [resBDpf] = forwardPSF_Pos(bdSize, realSize, laserPos, objctPos, patchNormal, kc, ks, normalization, sig);
    resBDpf = resBDpf / max(resBDpf(:));
    lc = 1e-3;
    resBDpf(resBDpf < lc) = 0;
    % if normFlag
    %     curNorm = sum(resBDpf(:) .^ 2);
    %     if curNorm > 1e-6
    %         resBDpf = resBDpf / curNorm;
    %     end
    % end
    % if longCompFlag
    %     resBDpf = imresize3(resBDpf, [bdSize]);
    % end
    curvolMat = permute(resBDpf, [2, 1, 3]);
    nlosR = reshape(curvolMat, [prod(bdSize), 1]);
    allpsf(:, count) = nlosR;
    if mod(count, psfPrintLen) == 0 | (count == 1)
        fprintf('|')
    end
end
fprintf('\n')


% for i = 1:32:1024
%     a = permute(reshape(full(allpsf(:, i)), bdSize), [3, 1, 2]);
%     figure;imshow(reshape(a, [128, 32 * 32]) * 100)
% end

% volshow(a)
% int64
% psf = allpsf;
% [psfX, psfY] = ind2sub(size(psf), find(psf));
% values = nonzeros(psf);
% Idxs = find(psf);
fullallpsf = full(allpsf);
% save('psf/sparsepsf500.mat', 'Idxs', 'values');
% save('psf/allpsf500.mat', 'allpsf');

% invMat = pinv(allpsf' * allpsf) * allpsf;

% save('psf/fullallpsf25022.mat', 'fullallpsf');
save('psf/psf_dyn_u.mat', 'fullallpsf');
% save('psf/psf723pos.mat', 'allPos');
% a = [ 0  0  3
%  4  0  5];

% [x, y] = find(a)
% save('psf/allpsf500.mat', 'a');




































