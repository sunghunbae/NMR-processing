# NMR-processing
NMR data conversion and processing scripts for NMRPipe and Sparky

## Bruker HNCO(hncogp3d or b_hncogp3d)
'''
#!/bin/csh

bruk2pipe -in ./ser \
  -bad 0.0 -aswap -DMX -decim 2040 -dspfvs 20 -grpdly 67.9862060546875  \
  -xN               768  -yN                64  -zN               128  \
  -xT               349  -yT                32  -zT                64  \
  -xMODE            DQD  -yMODE  Echo-AntiEcho  -zMODE        Complex  \
  -xSW         9803.922  -ySW         2483.855  -zSW         2465.483  \
  -xOBS         700.233  -yOBS          70.962  -zOBS         176.104  \
  -xCAR           4.772  -yCAR         117.069  -zCAR         176.197  \
  -xLAB              HN  -yLAB             15N  -zLAB             13C  \
  -ndim               3  -aq2D          States                         \
  -out ./fid/test%03d.fid -verb -ov
'''
