function [reconRealign, psfRealign] = TCSPCAlignment(bckRcon, bckPSF, alnPos, ZeroPos, zOffset, sampleLength)
    [reAlignR, reAlignGraph, cross1stRef] = alignTCSPCHelper(bckRcon, alnPos, ZeroPos, zOffset, sampleLength);
    reconRealign = {reAlignR, reAlignGraph, cross1stRef};
    [reAlignR, reAlignGraph, cross1stRef] = alignTCSPCHelper(bckPSF, alnPos, ZeroPos, zOffset, sampleLength);
    psfRealign = {reAlignR, reAlignGraph, cross1stRef};
    
end



