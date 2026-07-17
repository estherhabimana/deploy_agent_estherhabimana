This is a project that helps with project structure build automation

It has the following features:
 - Checks if Python is installed
 - Builds project structure skeleton
 - Can customise and adjust attendance check thresholds
 - Handles signal interruptions from the user (CTRL+C and archives the then old file). This archiving can only happen when it has already started creating the folder structure though otherwise it just terminates

To run the build_setup.sh script,
 - You must give it execute permissions with (chmod +x build_setup.sh) incase it doesn't have the permission as without it the script can't run
 - Execute it in CLI with ./build_setup.sh

Additionals:
 - Ensure dependent files in source_files(my own folder name) like json, the python script, the config, the students' dataset is available for successful running and producing output
 - You can adjust attendance thresholds as needed by adjusting the numbers in the config file, but you'll then have to update the value in the printed display inorder not to confuse the user

 - To activate the archive feature, press ctrl+c right after giving the directory name /version name/number, before you confirm if you want to setup your own config warning and failure values

My video link guiding you is here: https://youtu.be/uuWPELNlVTs
