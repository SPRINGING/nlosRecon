function [inPaintData] = badPtImPainting(badPtMap, nlosReshapeData)
	bdSize = size(nlosReshapeData);
	nlosRes = nlosReshapeData;
	badPtGrf = reshape(badPtMap, bdSize(1:2));
	
	[row,col] = find(badPtGrf);

	for i = 1:length(row)
	    votingPool = [row(i) - 1, col(i);
	                  row(i) + 1, col(i);
	                  row(i), col(i) - 1;
	                  row(i), col(i) + 1];
	    inPaintVec = zeros(1, 1, bdSize(3));
	    intCnt = 0;
	    for j = 1:size(votingPool, 1)
	        vtY = votingPool(j, 1);
	        vtX = votingPool(j, 2);
	        if vtY < bdSize(1) && vtY > 0 && vtX < bdSize(2) && vtX > 0 && badPtGrf(vtY, vtX) == 0
	            inPaintVec = inPaintVec + nlosRes(vtY, vtX, :);
	            intCnt = intCnt + 1;
	        end
	    end
	    if intCnt > 0
	        nlosRes(row(i), col(i), :) = inPaintVec / intCnt;
	    end
	end



	inPaintData = nlosRes;









