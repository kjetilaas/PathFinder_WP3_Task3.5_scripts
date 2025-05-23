Scripts to generate anomaly forcing from Euro Cordex files, for use in PATHFINDER project

## Description

This repository contains scripts to calculate scaling factors and anomalies from Euro-Cordex data. These can be used in combination with historical forcing files to produce future forcing.

## Steps to Use

1. **Clone the repository:**

    ```sh
    git clone https://github.com/kjetilaas/PathFinder_WP3_Task3.5_scripts.git
    cd PathFinder_WP3_Task3.5_scripts/
    ```

2. **Download data:**

    Use the `download_data.sh` script to download the necessary data files:

    ```sh
    ./download_data.sh
    ```

3. **Load necessary modules:**

    Ensure you have CDO loaded. For example, on CICERO machine "qbo":

    ```sh
    module purge
    module load CDO/1.9.8-foss-2019b
    ```

4. **Generate anomalies and scaling factors:**

    Run the `Generate_anomalies.sh` script to process the data and generate the output files:

    ```sh
    ./Generate_anomalies.sh
    ```

5. **Check the output:**

    The generated anomalies and scaling factors will be saved in the specified output directory. The python script `plot_results.py` can be used to plot the output, including timeseries for individual grid points, by modifying `selected_lat` and `selected_lon`. If no changes have been made to the scripts, the existing figures 

## Modifying Variables or Models (NB: this has not yet been tested, so modify with care)

If you need to modify the variables or use a different model combination, you will first need to generate new download scripts from the relevant ESGF server (for our model combination, this is https://esg-dn1.nsc.liu.se/search/esgf-liu/). .

For other variables, modify `variables` in `download_data.sh` and `generate_anomalies.sh`, e.g.: 
```sh
variablse=("huss" "rsds")
```

For other model combinations, modify the following variables in `generate_anomalies.sh`:
```sh
cordex_GCMmodel=MPI-M-MPI-ESM-LR
cordex_GCM_sim=r1i1p1
cordex_RCM=SMHI-RCA4_v1a
```

## Additional information for use with Yassso
Below are a couple of commands you can use to generate 5-yr mean values for a specific grid (here to use in the Yasso model), which can then be filled into a csv (for use in the Yasso model). 

From "Yasso_files/" run:
 ```sh
cdo -remapbil,yasso_grid.txt -timselmean,5 -selyear,2016/2100 -yearavg [ -mergetime ../input_files/rcp45/pr/pr_EUR-11_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_mon_20* ] pr_EUR-regridded_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_2016-2100_5yrmean.nc

cdo -remapbil,yasso_grid.txt -timselmean,5 -selyear,2016/2100 -yearavg [ -mergetime ../input_files/rcp45/tas/tas_EUR-11_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_mon_20* ] tas_EUR-regridded_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_2016-2100_5yrmean.nc
```

This will generate 5-year mean values remapped to a regular latlon grid with 0.1 degree resolution, which matches the grid of the csv file "Yasso_files/yasso_grid.txt". The python script "fill_yasso_csv.py" can then be used to read this file and fill it into the example csv file "Yasso_files/TP_EU_RCP45_3035_empty_short.csv"