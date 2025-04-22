import pandas as pd
import xarray as xr
import numpy as np
#script generated with help from copilot

# File paths
csv_file = "/div/no-backup-nac/users/kjetisaa/PathFinder_WP3_Task3.5_scripts/Yasso_files/TP_EU_RCP45_3035_empty_short.csv"
netcdf_tas_file = "/div/no-backup-nac/users/kjetisaa/PathFinder_WP3_Task3.5_scripts/Yasso_files/tas_EUR-regridded_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_2016-2100_5yrmean.nc"
netcdf_pr_file = "/div/no-backup-nac/users/kjetisaa/PathFinder_WP3_Task3.5_scripts/Yasso_files/pr_EUR-regridded_MPI-M-MPI-ESM-LR_rcp45_r1i1p1_SMHI-RCA4_v1a_2016-2100_5yrmean.nc"
output_csv = "/div/no-backup-nac/users/kjetisaa/PathFinder_WP3_Task3.5_scripts/Yasso_files/TP_EU_RCP45_3035_filled.csv"

# Load the CSV file
df = pd.read_csv(csv_file)

# Load the NetCDF file
ds_tas = xr.open_dataset(netcdf_tas_file)
ds_pr = xr.open_dataset(netcdf_pr_file)

# Iterate over each row in the CSV
for index, row in df.iterrows():
    print(f"Processing row {index + 1}/{len(df)}, lat: {row['lat']}, lon: {row['lon']}")
    lat, lon = row["lat"], row["lon"]    
    
    # Extract the time series for the corresponding grid point, if within 0.01 degrees
    tas_timeseries = ds_tas["tas"].sel(lat=lat, lon=lon, method="nearest", tolerance=0.01).values
    pr_timeseries = ds_pr["pr"].sel(lat=lat, lon=lon, method="nearest", tolerance=0.01).values
    
    # Replace NA values in T_* columns with the tas time series
    for i, col in enumerate([col for col in df.columns if col.startswith("T_")]):
        if pd.isna(row[col]):
            df.at[index, col] = tas_timeseries[i] if i < len(tas_timeseries) else np.nan
    # Replace NA values in T_* columns with the pr time series
    for i, col in enumerate([col for col in df.columns if col.startswith("P_")]):
        if pd.isna(row[col]):
            df.at[index, col] = pr_timeseries[i] if i < len(pr_timeseries) else np.nan

# Save the updated CSV
df.to_csv(output_csv, index=False)

print(f"Updated CSV saved to {output_csv}")