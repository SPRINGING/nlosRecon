

% dataList = {'rawData/histogram/noise_10000ms_1f_1.mat'
% 'rawData/histogram/pt_10000ms_1f_1.mat'
% 'rawData/histogram/S_10ms_1000f_1.mat'
% 'rawData/histogram/S_10ms_1000f_2.mat'
% 'rawData/histogram/S_10ms_1000f_3.mat'
% 'rawData/histogram/S_10ms_1000f_4.mat'
% 'rawData/histogram/statue_1000ms_1f_1.mat'
% 'rawData/histogram/statue_10ms_1000f_1.mat'
% 'rawData/histogram/statue_10ms_1000f_2.mat'
% 'rawData/histogram/statue_10ms_1000f_3.mat'
% 'rawData/histogram/statue_10ms_1000f_4.mat'}


% dataList = {'rawData/noise_10000ms_1f_1.mat'
% 'rawData/pt_10000ms_1f_1.mat'
% 'rawData/S_10ms_1000f_1.mat'
% 'rawData/S_10ms_1000f_2.mat'
% 'rawData/S_10ms_1000f_3.mat'
% 'rawData/S_10ms_1000f_4.mat'
% 'rawData/statue_1000ms_1f_1.mat'
% 'rawData/statue_10ms_1000f_1.mat'
% 'rawData/statue_10ms_1000f_2.mat'
% 'rawData/statue_10ms_1000f_3.mat'
% 'rawData/statue_10ms_1000f_4.mat'}




Heigt = 32;
Width = 32;
Depth = 1024;
curFrameData = zeros(Heigt, Width, 1024);
for j = 1:Heigt
	for k = 1:Width
	    transient = squeeze(curData(j, k, :));
	    transient(transient == 0) = [];
	    value = hist(transient, 0 : 1023);
		curFrameData(j, k, :) = value;
	end
end


frameForPlot = reshape(permute(curFrameData, [3, 1, 2]), [Depth, Heigt * Width]);
figure; imshow(frameForPlot)
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








