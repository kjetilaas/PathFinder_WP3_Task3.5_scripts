import xarray as xr
import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs

# Define variable and scenario
var='tas' #tas or pr
scenario='rcp45'
outdir='Figures/'

cordex_GCMmodel='MPI-M-MPI-ESM-LR'
cordex_GCM_sim='r1i1p1'
cordex_RCM='SMHI-RCA4_v1a' #CLMcom-CCLM4-8-17_v1, MPI-CSC-REMO2009_v1 SMHI-RCA4_v1a

selected_lat = 60.0  
selected_lon = 10.75  

def lat_lon_to_index(selected_lat, selected_lon, lat_values, lon_values):
    # Calculate the absolute difference between the desired lat/lon and the values in the lat/lon arrays
    lat_diff = np.abs(lat_values - selected_lat)
    lon_diff = np.abs(lon_values - selected_lon)

    # Find the indices of the minimum values in the difference arrays
    rlat, rlon = np.unravel_index(np.argmin(lat_diff + lon_diff), lat_diff.shape)

    return rlat, rlon

# Load the netCDF file
#ds = xr.open_dataset(f'/storage/no-backup-nac/PATHFINDER/EURO-CORDEX/{scenario}/{var}/{var}_EUR-11_{cordex_GCMmodel}_{scenario}_{cordex_GCM_sim}_{cordex_RCM}_anomalies_2005-2100.nc')
ds = xr.open_dataset(f'output_files/{scenario}/{var}/{var}_EUR-11_{cordex_GCMmodel}_{scenario}_{cordex_GCM_sim}_{cordex_RCM}_anomalies_2005-2100.nc')

# Convert from lat/lon to rlat/rlon
rlat, rlon = lat_lon_to_index(selected_lat, selected_lon, ds['lat'].values, ds['lon'].values)

# Select a point based on rlat/rlon coordinates
selected_point = ds[var][:, rlat, rlon]

# Calculate the average over the last 10 years (2091-2100)
last_10_years = ds[var][-120:].mean(dim='time').values

# Create a map plot for the average temperature/precip
plt.figure(figsize=(10, 6))
ax = plt.axes(projection=ccrs.PlateCarree())
plt.contourf(ds['lon'], ds['lat'], last_10_years, 60, transform=ccrs.PlateCarree())
ax.coastlines()
plt.colorbar(label=f'{var} ({ds[var].units})')
plt.title(f'Average {var}  Anomaly/Factor (2091-2100)')
plt.savefig(f"{outdir}/Anomalies_map_{var}_{cordex_GCMmodel}_{scenario}_{cordex_GCM_sim}_{cordex_RCM}.png")

# Calculate the yearly average temperature/precip
yearly_avg = selected_point.resample(time='Y').mean()

# Create a subplot for the time series of yearly data
plt.figure(figsize=(10, 6))
plt.subplot(2, 1, 1)
plt.plot(ds['time'][::12].values, yearly_avg)
plt.title(f'Yearly {var} at Point ({selected_lat}N,{selected_lon}E)')
plt.xlabel('Time')
plt.ylabel(f'{var} ({ds[var].units})')

# Create a subplot for the time series of July data
plt.subplot(2, 1, 2)
plt.plot(ds['time'][6::12].values, selected_point[6::12])
plt.title(f'July {var} at Point ({selected_lat}N,{selected_lon}E)')
plt.xlabel('Time')
plt.ylabel(f'{var} ({ds[var].units})')

plt.tight_layout()
plt.savefig(f"{outdir}/Anomalies_timeseries_{var}_{cordex_GCMmodel}_{scenario}_{cordex_GCM_sim}_{cordex_RCM}.png")