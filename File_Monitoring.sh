#!/usr/bin/bash

# Main script logic
path=$1
function check_input {
        cat <<EOF
                $0 <option> <path>-->path is required to monitor
EOF
}

if [ ${#path} -lt 1 ]; then
	check_input
        exit 1
fi

if [ ! -e $path ]; then 
	echo "Error: $path is not existed"
	exit 1
elif [ ! -d $path ]; then
	echo "Error: $path is not a director"
	exit 1
fi
path=$(realpath $1)

snapshot_file=$(dirname $path)/snapshotfil.txt
cat <<EOF
	Path=$path
	Snapshot_File=$snapshot_file
EOF

# Function to generate the snapshot
generate_snapshotfile() {
	find $path -type f -exec md5sum {} \;> "$snapshot_file"
}

# Function to compare snapshots
compare_snapshot() {

	local temp_file=$(mktemp)
	find $path -type f -exec md5sum {} \; > "$temp_file"
	added=$(diff -p "$snapshot_file" "$temp_file" | grep '^+ ' | awk '{print $3}')
	removed=$(diff -p "$snapshot_file" "$temp_file" | grep '^- ' | awk '{print $3}')
	modified=$(diff -p "$snapshot_file" "$temp_file" | grep '^! ' | awk '{print $3}')

if [ -n "$added" ] || [ -n "$removed" ] || [ -n "$modified" ]; then
	echo "INFO: Cheng detected"
		if [ -n "$added" ]; then
            		echo "INFO: Added file:"
            		echo "$added"
		fi
        	if [ -n "$removed" ]; then
          		echo "INFO: Removed file:"
        		echo "$removed"
		fi
	        if [ -n "$modified" ]; then
        	      	echo "INFO: Modified file:"
                	echo "$modified"
		fi
       		else
        		echo "INF: changed no detected:"
		fi
		# Clean up the temporary file
		rm -rf "$temp_file"
		}
select action in generate monitor "exit"; do
	case $action in
		generate)
			generate_snapshotfile
			echo "INF: snapshotfile generated"
			;;
		monitor)
        		compare_snapshot
			;;
		"exit")
			exit 0
			;;
		*)
			echo "ERROR: action is not available"
			;;
	esac
done

