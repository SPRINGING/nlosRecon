noiseDataList = {'rawData/noise_5000ms_1f_1.mat'
'rawData/noise_1000ms_1f_1.mat'
'rawData/noise_500ms_2f_1.mat'
'rawData/noise_300ms_3f_1.mat'
'rawData/noise_200ms_5f_1.mat'
'rawData/noise_100ms_10f_1.mat'
'rawData/noise_50ms_20f_1.mat'
'rawData/noise_25ms_40f_1.mat'};



noiseSaveList = {'rawData/noise_5000ms.mat'
				'rawData/noise_1000ms.mat'
				'rawData/noise_500ms.mat'
				'rawData/noise_300ms.mat'
				'rawData/noise_200ms.mat'
				'rawData/noise_100ms.mat'
				'rawData/noise_50ms.mat'
				'rawData/noise_25ms.mat'};


for count = 1:length(noiseDataList)
	curDataPath = noiseDataList{count}
	load(curDataPath);
	sz = size(allVideoData);
	bgData = zeros(sz(1:3));
	bgDataLength = size(allVideoData, 4);
	for i = 1:bgDataLength
		bgData = bgData + allVideoData(:, :, :, i);
	end
	allVideoData = bgData / bgDataLength;
	save(noiseSaveList{count}, 'allVideoData');
end







