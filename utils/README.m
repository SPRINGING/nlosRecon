顶层文件:

batchRespltGrid.m -> 多个结果可视化
resplt.m -> 单个结果精挑
batchSGDSolver.ipynb -> 线性优化(这个代码跑结果)
brdfDtGnPossion.m -> psf 生成

utils(每个顶层文件有各自的参数以及说明):

preProcess -> 数据预处理 将原始matlab采集到的数据转换为统计图形式
dataProcessVideoSeq -> 顺序数据处理,将预处理数据进行初步对齐
calibProcessGrid -> 对于处理数据进行矫正


总体过程: 
1. 调参
2. 跑brdfDtGnPossion生成psf
3. 跑优化算法

调参过程:
preProcess -> dataProcessVideoSeq ----> calibProcessGtid
									|
									--> noise2noise -> calibProcessGtid


优化算法:
jupyter notebook 打开后按照顺序跑就OK

filepath 改为相应文件

如resizeData中的文件:
	->  STD1Vid_data_calib_256_8142_1.mat
	->  STD1Vid_data_calib_256_8142_2.mat
	->  STD1Vid_data_calib_256_8142_3.mat
	->  STD1Vid_data_calib_256_8142_4.mat
	->  STD1Vid_data_calib_256_8142_5.mat
	->  STD1Vid_data_calib_256_8142_6.mat
	->  STD1Vid_data_calib_256_8142_7.mat

filepath则改成:

filepath = './resizeData/STD1Vid_data_calib_256_8142_{Count}.mat'.format(Count = str(count))

