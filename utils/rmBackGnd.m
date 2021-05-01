function [bckRcon, bckPSF] = rmBackGnd(rmRecon, rmPSF, rmNBck, rbConst);
rmPSF(1:rbConst, :) = rmPSF(1:rbConst, :) - rmNBck(1:rbConst, :);
rmRecon(1:rbConst, :) = rmRecon(1:rbConst, :) - rmNBck(1:rbConst, :);

bckRcon = rmRecon;
bckPSF = rmPSF;








