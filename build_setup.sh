#!/usr/bin/env bash
set -u

# setting up our structure directories and files
function setup_directory() {
	local dir="$1"
	[ -w "." ] || { echo "ERROR: no write permission in $(pwd). Try checking permissions with 'ls -lad .'"; exit 1; }

	echo "Setting up directory structure..."
	mkdir -p "./$dir" "./$dir/Helpers" "./$dir/reports"
	echo "Directory structure successfully setup!"
	echo "Adding initial files..."
	cp source_files/attendance_checker.py "./$dir"
	cp source_files/assets.csv "./$dir/Helpers"
	cp source_files/config.json "./$dir/Helpers"
	cp source_files/reports.log "./$dir/reports"
	echo "Initial files successfully added!"
}

function edit_config() {
	local dir="$1"
	local config="./$dir/Helpers/config.json"
	local new_warning_value new_failure_value

	while true; do
		read -p "Enter new warning value 0 - 100 (Default 75): " new_warning_value
		read -p "Enter new failure value 0 - 100 (Default 50): " new_failure_value

		if [[ $new_warning_value =~ ^[0-9]+$ && $new_failure_value =~ ^[0-9]+$ \
			&& $new_warning_value -le 100 && $new_failure_value -le 100 ]]
		then
			# we match keys explicitly instead of line numbers/hardcoded defaults,
			# so this is safe to re-run and doesn't depend on prior values.
			sed -E "s/(\"warning\"[[:space:]]*:[[:space:]]*)[0-9]+/\1${new_warning_value}/" "$config" > "./$dir/Helpers/temp.json" \
				&& mv "./$dir/Helpers/temp.json" "$config"
			sed -E "s/(\"failure\"[[:space:]]*:[[:space:]]*)[0-9]+/\1${new_failure_value}/" "$config" > "./$dir/Helpers/temp.json" \
				&& mv "./$dir/Helpers/temp.json" "$config"
			echo "Successfully set the warning value to '$new_warning_value' and the failure value to '$new_failure_value'"
			break
		else
			echo "New values must be whole numbers between 0 and 100"
		fi
	done
}

# handing signal interrupt of ctrl+c
function handle_interruption() {
	local dir="$1"
	if [ -n "$dir" ] && [ -d "$dir" ]
	then
		echo "Archiving $dir..."
		tar -cf "${dir}_archive.tar" "./$dir"
		echo "Cleaning workspace..."
		rm -rf "./$dir"
		echo "Setup successfully cancelled. Archived $dir and cleaned the workspace"
	fi
	exit
}

# checking if python is installed on system
function python3_check() {
	echo "Verifying if python3 is installed on this system..."
	if command -v python >/dev/null 2>&1 && python --version 2>&1 | grep -q "Python 3\."
	then
		echo "Verification done! python3 is installed on this system"
	else
		echo "Verification done! python3 is not installed on this system"
	fi
}

# our main function

function setup() {
	local version directory_name choice

	trap 'echo; echo "Successfully cancelled. No changes were made"; exit' INT

	while true; do
		read -p "Enter tracker version (e.g: v1): " version
		directory_name="attendance_tracker_$version"

		if [ -d "$directory_name" ]
		then
			echo "Try a different version. $directory_name already exists"
			continue
		fi

		# Only arm the cleanup trap once we're about to create the directory
		trap "handle_interruption '$directory_name'" INT

		setup_directory "$directory_name"

		while true; do
			read -p "Do you want to setup your own warning and failure values? [y/n]: " choice

			case "$choice" in
				y)
					edit_config "$directory_name"
					python3_check
					break
					;;
				n)
					echo "Successfully setup the project!"
					python3_check
					break
					;;
				*)
					echo "Invalid choice choose between [y/n]"
					;;
			esac
		done
		break
	done

	trap - INT
}

setup