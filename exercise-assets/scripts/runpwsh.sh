#!/bin/bash
#: Title:      : runpwsh.sh
#: Date:       : 2025-02-10
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
#
#                Help will be stored to the .help directory. That
#                directory is mounted as READ-WRITE. Beware!
#: Options     : [ARGS]..
#
#: === Examples ====
#:   runbash.sh
#.   runbash.sh 'Update-Help -DestinationPath /srv/powershell-help'
#:   runbash.sh scripts/hello.sh arg1 arg2 arg3

LOCAL_HELP="$(pwd)/.help/powershell-help"
DOCKER_HELP="/srv/powershell-help"
SCRIPT_DIR="scripts"
declare -a POSITIONAL=()
image_name=   # Set by choose_image()

choose_image_by_architecture() {
    case $(uname -m) in
        arm64|aarch64)
            image_name="mcr.microsoft.com/powershell:mariner-2.0-arm64"
            ;;
        *)
            image_name="mcr.microsoft.com/powershell:latest"
            ;;
    esac
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

run_docker_container_with_only_pwsh() {
    docker container run --rm \
        --interactive --tty \
        --name skriptiohjelmointi-pwsh-copyhelp \
        --mount type=bind,source="$(pwd)",target=/app,readonly \
        --mount type=bind,source="${LOCAL_HELP}",target=${DOCKER_HELP} \
        "$image_name"
}

run_docker_container_with_script_n_args() {
    docker container run --rm \
        --interactive --tty \
        --name skriptiohjelmointi-pwsh-copyhelp \
        --mount type=bind,source="$(pwd)",target=/app,readonly \
        --mount type=bind,source="${LOCAL_HELP}",target=${DOCKER_HELP} \
        --workdir /app \
        "$image_name" pwsh "${POSITIONAL[@]}"
}

main() {
    # Not using getopts. Give all to Docker.
    POSITIONAL=("$@")

    # Choose the correct image based on the architecture
    # ARM64 or aarch64 is likely macOS or Raspberry Pi
    choose_image_by_architecture

    # Handle scripts directory  
    check_directory_exists "$SCRIPT_DIR"
    check_directory_exists "$LOCAL_HELP"
    
    if [ ${#POSITIONAL[@]} -eq 0 ]; then
        echo "No script provided. Starting interactive shell session."
        run_docker_container_with_only_pwsh
    else
        check_script_exists "${POSITIONAL[0]}"
        run_docker_container_with_script_n_args "${POSITIONAL[@]}"
    fi
}

# Run the main function with all script arguments
main "$@"
