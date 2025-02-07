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
#: Options     : [script_name] [image_name]
#
#: === Examples ====
#:   runbash.sh
#:   runbash.sh '' ubuntu:20.04
#:   runbash.sh scripts/hello.sh
#:   runbash.sh scripts/hello.sh ubuntu:20.04

# Global static var
SCRIPT_DIR="scripts"
DEFAULT_IMAGE="ubuntu:24.04"

check_directory_exists() {
    if [ ! -d $1 ]; then
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

check_script_no_whitespace() {
    if [[ "$1" =~ [[:space:]] ]]; then
        echo "[ERROR] Script name cannot contain whitespace." >&2
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

run_docker_container() {
    local cmd="${1}"
    local image="${2}"
    
    docker container run --rm \
      -it \
      --name skriptiohjelmointi-bash \
      --mount type=bind,source="$(pwd)/${SCRIPT_DIR}",target=/app,readonly \
      $image \
      $cmd
}

main() {
    # Handle scripts directory  
    check_directory_exists "$SCRIPT_DIR"
    make_all_scripts_executable "${SCRIPT_DIR}/*.sh"

    # Default to Dockerfile CMD (e.g. /bin/bash)
    # You can check it with: docker inspect <image_name>
    docker_command=""

    # Get arguments
    script=${1:-}
    
    if [[ $script ]]; then

        check_script_exists "$script"
        check_script_no_whitespace "$script"
        
        # Set the command to run inside the container
        script_basename=$(basename "$script")
        docker_command="/app/$script_basename"
    fi

    image_name=${2:-$DEFAULT_IMAGE}
    run_docker_container "${docker_command}" "${image_name}"
}

# Run the main function with all script arguments
main "$@"
