#!/bin/sh

script_dir=Download_scripts/
indir=input_files/ #/div/no-backup/CORDEX/EUR-11/

#Modify to relevant cordex file names
cordex_GCMmodel=MPI-M-MPI-ESM-LR
cordex_GCM_sim=r1i1p1
cordex_RCM=SMHI-RCA4_v1a #CLMcom-CCLM4-8-17_v1, MPI-CSC-REMO2009_v1
cordex_hist_model=${cordex_GCMmodel}_historical_${cordex_GCM_sim}_${cordex_RCM}

variables=("pr" "tas")
scenarios=("historical" "rcp26" "rcp45" "rcp85")

for var in "${variables[@]}"; do
    for scenario in "${scenarios[@]}"; do
        file=$script_dir/WGET_${var}_EUR-11_${cordex_GCMmodel}_${scenario}_${cordex_GCM_sim}_${cordex_RCM}.sh; 
        echo $file       
        if [ -f $file ]; then
            echo "Downloaded $var $scenario"
            bash $file -s 
            mkdir -p $indir/$scenario/$var/
            mv ${var}_EUR-11_${cordex_GCMmodel}_${scenario}_${cordex_GCM_sim}_${cordex_RCM}*.nc $indir/$scenario/$var/
        else
            echo "Failed to download $var $scenario"
        fi
    done
done
done      