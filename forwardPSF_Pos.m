function [resBDpf] = forwardPSF_Pos(bdSize, realSize, laserPos, objctPos, patchNormal, kc, ks, normalization, sig)

    x = linspace(0, realSize(1), bdSize(1));
    y = linspace(0, realSize(2), bdSize(2));
    z = linspace(0, realSize(3), bdSize(3));
    [Y, X, Z] = ndgrid(y, x, z);

    % x0 = X(:, :, 1);
    % y0 = Y(:, :, 1);

    rLaser = sqrt( ...
                (objctPos(1) - laserPos(1)) .^ 2 + ...
                (objctPos(2) - laserPos(2)) .^ 2 + ...
                (objctPos(3)) .^ 2 ... 
            );

    rObject = sqrt( ...
                (objctPos(1) - X) .^ 2 + ...
                (objctPos(2) - Y) .^ 2 + ...
                (objctPos(3)) .^ 2 ... 
            );

    if normalization
        energy = 1;
    else
        energy = 1 ./ (rLaser .^ 2 * rObject .^ 2); 
    end

    resBD = zeros(bdSize);
    resBD = energy .* exp(-(rLaser + rObject - Z) .^ 2 ./ (sig ^ 2));

    lambda = 0.05;
    k = 1:5;
    pf = reshape(lambda .^ k * exp(-lambda) ./ factorial(k), [1, 1, length(k)]);
    resBDpf = convn(resBD, pf, 'same');


















