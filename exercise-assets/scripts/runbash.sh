#!/bin/bash
#: Title:      : runbash.sh
#: Date:       : 2025-01-31
#: Author      : Jani Sourander
#: Version     : 1.0
#: Description : Run a script inside a Docker container or 
#                interactive shell session. The script must be
#                located in the "scripts" directory relative to
#                current working directory.
#
#                The script directory is mounted as READ-ONLY, 
#                thus protecting your host's file system from  
#                script logic mistakes.
#: Options     : [-h] [-i image_name] [ARGS]..
#
#: === Examples ====
#:   runbash.sh
#:   runbash.sh -i ubuntu:20.04
#:   runbash.sh -i ubuntu:20.04 scripts/hello.sh
#:   runbash.sh -i ubuntu:20.04 scripts/hello.sh arg1 arg2 arg3
#:   runbash.sh scripts/hello.sh arg1 arg2 arg3

# Global static var
SCRIPT_DIR="scripts"

# Global variables
IMAGE_NAME="ubuntu:24.04"
declare -a POSITIONAL


show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-i image_name] [ARGS]..
Run a script inside a Docker container or interactive shell session. The script must be
located in the "scripts" directory relative to current working directory.

    -h          Display this help and exit
    -i          Docker image name
    ARGS        Arguments to pass to the script
EOF
}

parse_arguments() {
    local OPTIND=1  
    local optstring="hi:"

    while getopts "$optstring" opt; do
        case $opt in
            h)
                show_help
                exit 0
                ;;
            i)
                IMAGE_NAME=$OPTARG
                ;;
            *)
                show_help >&2
                exit 1
        esac
    done


    # Remove the options we parsed above
    shift $((OPTIND-1))

    # Correct
    POSITIONAL=("$@")
}

check_directory_exists() {
    if [ ! -d "$1" ]; then
        echo "[ERROR] Directory '${1}' does not exist." >&2
        exit 1
    fi
}

check_script_exists() {
    if [ ! -f "$1" ]; then
        echo "[ERROR] Script '${1}' does not exist." >&2
        exit 1
    fi
}

make_script_executable() {
    local filepath="$1"
    if [[ ! -x $filepath ]]; then
        echo "[INFO] Making '${1}' executable."
        chmod +x "$1"
    fi
}

make_all_scripts_executable() {
    local filespec="$1"
    for script in $filespec; do
        make_script_executable "$script"
    done
}

run_docker_container_with_only_bash() {
    docker container run --rm \
      --interactive --tty \
      --name skriptiohjelmointi-bash \
      --mount type=bind,source="$(pwd)",target=/app,readonly \
      "$IMAGE_NAME"
}

run_docker_container_with_script_n_args() {
    docker container run --rm \
      --interactive --tty \
      --name skriptiohjelmointi-bash \
      --mount type=bind,source="$(pwd)",target=/app,readonly \
      --workdir /app \
      "$IMAGE_NAME" "${POSITIONAL[@]}"
}

main() {
    # Handle scripts directory  
    check_directory_exists "$SCRIPT_DIR"
    make_all_scripts_executable "${SCRIPT_DIR}/*.sh"

    parse_arguments "$@"
    
    if [ ${#POSITIONAL[@]} -eq 0 ]; then
        echo "No script provided. Starting interactive shell session."
        run_docker_container_with_only_bash
    else
        check_script_exists "${POSITIONAL[0]}"
        run_docker_container_with_script_n_args "${POSITIONAL[@]}"
    fi
}

# Run the main function with all script arguments
main "$@"
