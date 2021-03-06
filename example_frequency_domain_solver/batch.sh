#!/bin/bash
# Note: in multiprocessing environment, run this script e.g. as `mpirun -np 2 ./batch.sh'

if [ -z $NP ] ; then NP=2 ; fi			 # number of processors
COMMAND="mpirun -np $NP ../scatter.py model=SphereWire comment=time-domain resolution=4u simtime=100p wirethick=10u cellsize=50e-6 padding=20e-6 radius=13e-6"

## Generate frequency-domain results
for ff in `seq 1000 20 1300`; do
     $COMMAND frequency=${ff}e9
done

## Extract the reflection (|s11|, second column) and transmission (|s12|, fourth column)
ls -1t *frequency=*dat   |   xargs cat   >   all.dat
echo "#param comment,frequency-domain" > r.dat
cat all.dat  |  sed -e '/#/d'  |  cut -d' ' -f'1,2'  |  sort -g  >>  r.dat
echo "#param comment,frequency-domain" > t.dat
cat all.dat  |  sed -e '/#/d'  |  cut -d' ' -f'1,4'  |  sort -g  >>  t.dat

## Gather the frequency-domain E_x shapes
convert SphereArray*frequency*/*png -resize 200% -border 2 +append  Ex_field-frequency_scan.png

## Clean up
rm    SphereArray*frequency*.dat
rm    SphereArray*frequency*.png
rm -r SphereArray*frequency*/

## Run one time-domain simulation for comparison
$COMMAND 
#../effparam.py
../plot_multiline.py SphereArray_simtime=*.dat r.dat  --paramname comment

