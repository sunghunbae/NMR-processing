# NMR-processing
NMR data conversion and processing scripts for NMRPipe and Sparky

## Convert Bruker NMR data to NMRpipe

  * 3D HNCO - hncogp3d or b_hncogp3d
  * 3D HN(CA)CO - hncacogp3d or b_hncacogp3d
  * 3D HNCA - hncagp3d or b_hncagp3d
  * 3D HN(CO)CA - hncocagp3d or b_hncocagp3d

#### Example NMRPipe script
```
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
```
### Process NMRpipe data

#### Example NMRPipe script
```
#!/bin/csh

xyz2pipe -in fid/test%03d.fid -x -verb \
| nmrPipe  -fn SOL                                    \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5    \
| nmrPipe  -fn ZF -size 2048                          \
| nmrPipe  -fn FT                                     \
| nmrPipe  -fn PS -p0 -77  -p1 0.0 -di                \
| nmrPipe  -fn EXT -left -sw -verb                    \
| nmrPipe  -fn POLY -auto \
| nmrPipe  -fn TP                                     \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 1.0    \
| nmrPipe  -fn ZF -size 64                           \
| nmrPipe  -fn FT                                     \
| nmrPipe  -fn PS -p0 90 -p1 0 -di                    \
| nmrPipe  -fn TP                                     \
| nmrPipe  -fn POLY -auto \
| pipe2xyz -out ft/test%03d.ft2 -x

xyz2pipe -in ft/test%03d.ft2 -z -verb               \
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 1 -c 0.5  \
| nmrPipe  -fn ZF -size 128                         \
| nmrPipe  -fn FT -alt                              \
| nmrPipe  -fn PS -p0 0.0 -p1 0.0 -di               \
| nmrPipe  -fn POLY -auto                           \
| pipe2xyz -out ft/test%03d.ft3 -z
```

### Convert processed NMRPipe data to a Sparky .ucsf file

```
xyz2pipe -in ft/test%03d.ft3 > a.pipe
pipe2ucsf a.pipe a.ucsf
```
