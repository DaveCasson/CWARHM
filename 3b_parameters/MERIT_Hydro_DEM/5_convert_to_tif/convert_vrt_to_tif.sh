# Convert the MERIT .vrt to .tif 

# modules
module load nixpkgs/16.09 gcc/5.4.0 gdal/2.1.3


#---------------------------------
# Specify settings
#---------------------------------

# --- Location of source data
dest_line=$(grep -m 1 "parameter_dem_vrt2_path" ../../../0_controlFiles/control_active.txt) # full settings line
source_path=$(echo ${dest_line##*|})   # removing the leading text up to '|'
source_path=$(echo ${source_path%% #*}) # removing the trailing comments, if any are present

# Specify the default path if needed
if [ "$source_path" = "default" ]; then
  
 # Get the root path and append the appropriate install directories
 root_line=$(grep -m 1 "root_path" ../../../0_controlFiles/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%% #*})

 # domain name
 domain_line==$(grep -m 1 "domain_name" ../../../0_controlFiles/control_active.txt)
 domain_name=$(echo ${domain_line##*|}) 
 domain_name=$(echo ${domain_name%% #*})
 
 # source path
 source_path="${root_path}/domain_${domain_name}/parameters/dem/4_domain_vrt"

fi

# --- Location where converted data needs to go
dest_line=$(grep -m 1 "parameter_dem_tif_path" ../../../0_controlFiles/control_active.txt) # full settings line
dest_path=$(echo ${dest_line##*|})   # removing the leading text up to '|'
dest_path=$(echo ${dest_path%% #*}) # removing the trailing comments, if any are present

# Specify the default path if needed
if [ "$dest_path" = "default" ]; then
  
 # Get the root path and append the appropriate install directories
 root_line=$(grep -m 1 "root_path" ../../../0_controlFiles/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%% #*})

 # domain name
 domain_line==$(grep -m 1 "domain_name" ../../../0_controlFiles/control_active.txt)
 domain_name=$(echo ${domain_line##*|}) 
 domain_name=$(echo ${domain_name%% #*})
 
 # destination path
 dest_path="${root_path}/domain_${domain_name}/parameters/dem/5_elevation"
fi

# Make destination directory 
mkdir -p $dest_path

# --- Filenames
# Source file
vrt_file=$(ls $source_path/*.vrt)

# Find the name of the output file from control file
name_line=$(grep -m 1 "parameter_dem_tif_name" ../../../0_controlFiles/control_active.txt) # full settings line
dest_name=$(echo ${name_line##*|})   # removing the leading text up to '|'
dest_name=$(echo ${dest_name%% #*}) # removing the trailing comments, if any are present

# Make the destination path+name
tif_file="${dest_path}/${dest_name}

#---------------------------------
# Create .tif file
#---------------------------------
gdal_translate -co "COMPRESS=DEFLATE" $vrt_file $tif_file


#---------------------------------
# Code provenance
#---------------------------------
# Generates a basic log file in the domain folder and copies the control file and itself there.
# Make a log directory if it doesn't exist
log_path="${dest_path}/_workflow_log"
mkdir -p $log_path

# Log filename
today=`date '+%F'`
log_file="${today}_compile_log.txt"

# Make the log
this_file='convert_vrt_to_tif.sh'
echo "Log generated by ${this_file} on `date '+%F %H:%M:%S'`"  > $log_path/$log_file # 1st line, store in new file
echo 'Converted MERIT .vrt into .tif.' >> $log_path/$log_file # 2nd line, append to existing file

# Copy this file to log directory
cp $this_file $log_path