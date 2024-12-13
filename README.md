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

    Ensure you have the required modules loaded. For example, on CICERO machine "qbo":

    ```sh
    module purge
    module load CDO/1.9.8-foss-2019b
    ```

4. **Modify relevant variables:**

    Update the script variables to match your specific dataset and paths. For example, in `Generate_anomalies.sh`:

    ```sh
    cordex_GCMmodel=MPI-M-MPI-ESM-LR
    cordex_GCM_sim=r1i1p1
    cordex_RCM=SMHI-RCA4_v1a
    indir=input_files/
    outdir=output_files/
    ```

    The script currently processes `tas` and `pr` variables. If you need to process other variables or use a different model combination, you will need to update the dataset and generate new download scripts accordingly.

5. **Generate anomalies and scaling factors:**

    Run the `Generate_anomalies.sh` script to process the data and generate the output files:

    ```sh
    ./Generate_anomalies.sh
    ```

6. **Check the output:**

    The generated anomalies and scaling factors will be saved in the specified output directory.

## Additional Information

For more details on the methodology and usage, refer to the comments within the scripts and the references provided in the script headers. Questions can be posted as issues, or via email. 