

dataList = {'rawData/histogram/data_50ms_20f_1.mat'
'rawData/histogram/data_50ms_20f_2.mat'
'rawData/histogram/data_50ms_20f_3.mat'
'rawData/histogram/data_50ms_20f_4.mat'
'rawData/histogram/data_50ms_20f_5.mat'
'rawData/histogram/noise_10000ms_1f_1.mat'
'rawData/histogram/psf_10000ms_1f_1.mat'}


saveList = {'rawData/data_50ms_20f_1.mat'
'rawData/data_50ms_20f_2.mat'
'rawData/data_50ms_20f_3.mat'
'rawData/data_50ms_20f_4.mat'
'rawData/data_50ms_20f_5.mat'
'rawData/noise_10000ms_1f_1.mat'
'rawData/psf_10000ms_1f_1.mat'}



for count = 1:length(dataList)
	curDataPath = dataList{count};
	disp(curDataPath);
	load(curDataPath);
	dtLength = length(allFrame);
	Heigt = 32;
	Width = 32;
	Depth = 1024;
	allVideoData = zeros(Heigt, Width, Depth, dtLength);
	for i = 1:dtLength
		disp(i);
		curData = allFrame{i};
		curFrameData = zeros(Heigt, Width, 1024);
		for j = 1:Heigt
			for k = 1:Width
			    transient = squeeze(curData(j, k, :));
			    transient(transient == 0) = [];
			    value = hist(transient, 0 : 1023);
				curFrameData(j, k, :) = value;
			end
		end
		allVideoData(:, :, :, i) = curFrameData;
	end
	save(saveList{count}, 'allVideoData');
end


% dataList = {'rawData/histogram/noise_100ms_100f_1.mat';
% 			'rawData/histogram/pt_100ms_100f_1.mat';
% 			};


% saveList = {'rawData/noise_100ms_100f_1.mat';
% 			'rawData/pt_100ms_100f_1.mat'
% 			};

% for count = 1:length(dataList)
% 	curDataPath = dataList{count};
% 	disp(curDataPath);
% 	load(curDataPath);
% 	dtLength = length(allFrame);
% 	Heigt = 32;
% 	Width = 32;
% 	Depth = 1024;
% 	allVideoData = zeros(Heigt, Width, Depth, 1);
% 	for i = 1:dtLength
% 		disp(i);
% 		curData = allFrame{i};
% 		curFrameData = zeros(Heigt, Width, 1024);
% 		for j = 1:Heigt
% 			for k = 1:Width
% 			    transient = squeeze(curData(j, k, :));
% 			    transient(transient == 0) = [];
% 			    value = hist(transient, 0 : 1023);
% 				curFrameData(j, k, :) = value;
% 			end
% 		end
% 		allVideoData(:, :, :, 1) = allVideoData(:, :, :, 1) + curFrameData;
% 	end
% 	save(saveList{count}, 'allVideoData');
% end








