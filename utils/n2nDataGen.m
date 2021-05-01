fileSize = 10;
trainData = [];
trainLabl = [];

for i = 1:2
	load(sprintf('./resizeData/DynS/dynS_data_VidSeq_%d.mat', i) , 'vidSeq');
	curData = vidSeq(:, :, :, 1:(end-1));
	curLabl = vidSeq(:, :, :, 2:end);
	trainData = cat(4, trainData, curData);
	trainLabl = cat(4, trainLabl, curLabl);
end

save('dynTrainData.mat', 'trainData', 'trainLabl');


