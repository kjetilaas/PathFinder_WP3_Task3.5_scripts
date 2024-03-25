#!/bin/sh
#Program to calculate scaling factors and anomalies from Euro-Cordex 1996-2005.
#These can be used in combination with historical forcing files to produce future forcing (see e.g. Koven et al. 2015, PNAS or 
#https://escomp.github.io/ctsm-docs/versions/release-clm5.0/html/users_guide/running-special-cases/Running-with-anomaly-forcing.html).
#The current example is for tenperature (tas) from RCP8.5, using NorESM1 Climate model downscaled with DMI HIRHAM5.
#The result is a single output file with anomalies (for states, like temperature) or scaling factors (for fluxes, like precipitation).
#Program uses CDO (https://code.mpimet.mpg.de/projects/cdo)

#Modify to relevant cordex file names
cordex_hist_model=NCC-NorESM1-M_historical_r1i1p1_DMI-HIRHAM5_v3
cordex_GCMmodel=NCC-NorESM1-M
cordex_GCM_sim=r1i1p1
cordex_RCM=DMI-HIRHAM5_v3

#Path to folders with cordex files and output files
indir=/div/no-backup/CORDEX/EUR-11/
outdir=/storage/no-backup-nac/PATHFINDER/EURO-CORDEX/

#Define varialbe and scenario
var=pr #pr, tas 
scenario=rcp85 #rcp45, rcp85

anomaly_list="tas uas vas ps huss"
scale_list="pr rsds rlds" 

syear_baseline=1996 #NB: climatology calculation is currently partly hardcoded to 1996-2005.
eyear_baseline=2015 #NB: climatology calculation is currently partly hardcoded to 1996-2005.

#Define derived paths and base filenames
infile_hist_basename=$indir/historical/${var}/${var}_EUR-11_${cordex_GCMmodel}_historical_${cordex_GCM_sim}_${cordex_RCM}_mon
outfile_baseclimate=$outdir/${var}_EUR-11_${cordex_hist_model}_yearmonavg_$syear_baseline-$eyear_baseline.nc
outfile_anomaly=${var}_EUR-11_${cordex_GCMmodel}_${scenario}_${cordex_GCM_sim}_${cordex_RCM}_anomalies_2005-2090.nc

infile_scenario_path=$indir/$scenario/$var/
infile_scenario_basename=${var}_EUR-11_${cordex_GCMmodel}_${scenario}_${cordex_GCM_sim}_${cordex_RCM}_mon


###Download data from https://esgf-data.dkrz.de/search/esgf-dkrz/
#Search for "cordex", "historical"/"rcp85","mon", "tas"/"pr", "EUR-11", "HIRHAM5", "v3". 
#Download with wget script (use -s to scip credentials), e.g.:
#bash WGET_pr_EUR-11_NCC-NorESM1-M_rcp45_r1i1p1_DMI-HIRHAM5_v3_mon.sh -s 

###Generate basline climatology. Currently partly hardcoded 1996-2015 baseline period. Always use rcp45 for 2006-2015 (scenario period in CMIP5)
cdo ymonavg -selyear,$syear_baseline/$eyear_baseline -mergetime ${infile_hist_basename}_199101-200012.nc ${infile_hist_basename}_200101-200512.nc \
    $indir/rcp45/$var/${var}_EUR-11_${cordex_GCMmodel}_rcp45_${cordex_GCM_sim}_${cordex_RCM}_mon_200601-201012.nc \
    -selyear,2011/2015 $indir/rcp45/$var/${var}_EUR-11_${cordex_GCMmodel}_rcp45_${cordex_GCM_sim}_${cordex_RCM}_mon_201101-202012.nc \
    $outfile_baseclimate

#Merge data and split by month (for calculating running mean)
mkdir -p $outdir/$scenario/$var/

cdo -splitmon -mergetime -selyear,1996/2000 ${infile_hist_basename}_199101-200012.nc ${infile_hist_basename}_200101-200512.nc $infile_scenario_path/$infile_scenario_basename* $outdir/$scenario/$var/temp_mon_${var}_1996-2100_

#Calculate running mean
for file in $outdir/$scenario/$var/temp_mon_${var}_1996-2100_*; do
    echo $file
    cdo runmean,21 $file $file.runmean.nc 
done

#Merge the 12 monthly timeseries, and split by year
cdo -mergetime $outdir/$scenario/$var/temp_mon_${var}_1996-2100_*.runmean.nc $outdir/$scenario/$var/temp_${var}_runmean_all.nc
cdo splityear $outdir/$scenario/$var/temp_${var}_runmean_all.nc $outdir/$scenario/$var/temp_year_${var}_

#Subtract/divide by baseyear to calculate anomalies/scaling factors
if [[ " ${anomaly_list[@]} " =~ " ${var} " ]]; then
    echo "Calculate anomalies"
    for file in $outdir/$scenario/$var/temp_year_${var}_*; do    
        cdo sub $file $outfile_baseclimate $file.anomaly.nc
    done
elif [[ " ${scale_list[@]} " =~ " ${var} " ]]; then
    echo "Calculate scaling factors"
    for file in $outdir/$scenario/$var/temp_year_${var}_*; do    
        cdo div $file $outfile_baseclimate $file.anomaly_temp.nc
        cdo -setrtoc,5,Inf,5 -setrtoc,-Inf,0,0 $file.anomaly_temp.nc $file.anomaly.nc
    done
else
    echo "Variable not in lists"
fi

cdo mergetime $outdir/$scenario/$var/temp_year_${var}_*.anomaly.nc $outdir/$scenario/$var/$outfile_anomaly

rm $outdir/$scenario/$var/temp*
