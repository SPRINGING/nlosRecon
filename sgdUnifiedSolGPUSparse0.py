import h5py
import numpy as np
import torch
import scipy.io as sio
import os
import matplotlib.pyplot as plt
os.getcwd()

print("Start constructing A matrix ...")
filepath = 'psf/psf_n011116_n070516_011164.mat'
print(filepath)
arrays = {}
f = h5py.File(filepath)
for k, v in f.items():
    arrays[k] = np.array(v)
A = torch.from_numpy(arrays['fullallpsf'].T).float()

indices = torch.nonzero(A).t()
values = A[indices[0], indices[1]]
A = torch.sparse.FloatTensor(indices, values, A.size())
print("finished")


print("Start constructing B matrix ...")
videoLength = 4
B = torch.zeros([A.shape[0], videoLength])
for count in range(1, videoLength+1):       
    filepath = './resizeData/StGrid{Count}_data_calib_256_8142_110.mat'.format(Count = str(count))
    print(filepath)
    arrays = {}
    f = h5py.File(filepath)
    for k, v in f.items():
        arrays[k] = np.array(v)
    b = torch.from_numpy(arrays['inPaintDataR']).float().reshape([A.shape[0], -1])
    b = b / torch.max(b)
    b[b < 0] = 0;
    B[:, count:(count + 1)] = b;


del arrays
print("finished")


cudaDevNum = 0
print('cuda: %d' % (cudaDevNum))
Agpu = A.cuda(cudaDevNum)


dim = A.shape[1]
regulizerAmt = 1;

x = torch.autograd.Variable(torch.ones(dim, 1))
x = x.cuda(cudaDevNum)
x.requires_grad_()

B = B.cuda(cudaDevNum)
batchDesTimes = 100

print("Start optimizing")
for count in range(100):
    path = "./allResults/B%03d" % (count)
    os.mkdir(path);
    for zShift in range(videoLength + 1):
        b = B[:, zShift:(zShift + 1)]
        step_size = 5e-4
        for i in range(batchDesTimes):
            stepNow = step_size
            loss = torch.norm(torch.matmul(Agpu, x) - b, p=2) + regulizerAmt * torch.norm(x, 2)
            x.data = x.data.clamp(0,1)
            loss.backward()
            x.data -= stepNow * x.grad.data # step
            x.grad.data.zero_()
        step_size = 1e-6
        for i in range(batchDesTimes):
            stepNow = step_size
            loss = torch.norm(torch.matmul(Agpu, x) - b, p=2)  + regulizerAmt * torch.norm(x, 2)
            loss.backward()
            x.data = x.data.clamp(0,1)
            x.data -= stepNow * x.grad.data # step
            x.grad.data.zero_()
        saveLos = np.float(loss.detach().cpu().numpy());
        print('Loss is %s at iteration %i' %  (saveLos, zShift))
    xbest = x.detach().cpu().numpy()#.reshape(32, 32,32)
    saveLos = np.float(loss.detach().cpu().numpy());
    print('Loss is %s at iteration %i' %  (saveLos, zShift))
    savepath = path + "/resH{zVal}_{res}.mat".format(zVal = zShift, res = i)
    pltpath = path + "/resH{zVal}_{res}.png".format(zVal = zShift, res = i)
    for zShift in reversed(range(videoLength)):
        b = B[:, zShift:(zShift + 1)]
        step_size = 1e-6
        for i in range(batchDesTimes * 2):            
            stepNow = step_size
            loss = torch.norm(torch.matmul(Agpu, x) - b, p=2) + regulizerAmt * torch.norm(x, 2)
            x.data = x.data.clamp(0,1)
            loss.backward()
            x.data -= stepNow * x.grad.data # step
            x.grad.data.zero_()
            # x.requires_grad_()
        step_size = 1e-6
        for i in range(batchDesTimes * 2):
            stepNow = step_size
            loss = torch.norm(torch.matmul(Agpu, x) - b, p=2)  + regulizerAmt * torch.norm(x, 2)
            loss.backward()
            x.data = x.data.clamp(0,1)
            x.data -= stepNow * x.grad.data # step
            x.grad.data.zero_()
        xbest = x.detach().cpu().numpy()#.reshape(32, 32,32)
        saveLos = np.float(loss.detach().cpu().numpy());
        print('Loss is %s at iteration %i' %  (saveLos, zShift))
        savepath = path + "/resH{zVal}_{res}.mat".format(zVal = zShift, res = i)
        pltpath = path + "/resH{zVal}_{res}.png".format(zVal = zShift, res = i)
        sio.savemat(savepath, mdict={'Results': xbest})
        prevloss = loss
        b_vis = b.cpu().detach().reshape((128, -1)).numpy() 
        b_cal = torch.matmul(Agpu, x).cpu().detach().reshape((128, -1)).numpy()
        plt.imshow(np.abs(b_vis - b_cal))
        plt.colorbar()
        plt.savefig(pltpath)
        plt.close()
        
        
        
        
        
        
          