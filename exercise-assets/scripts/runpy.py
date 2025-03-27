#!/usr/bin/env python3

import argparse
import subprocess
import shlex

from pathlib import Path


def resolve_scripts_dir(script: str):
    if script:
        p = Path(script).parent  # scripts/a.py -> scripts
    else:
        p = Path.cwd() / "scripts"  # $(pwd)/scripts
    return p.resolve()


def construct_docker_command(image, python_cmd: list, script: str, args: list):
    scripts_dir = resolve_scripts_dir(script)

    cmd = [
        "docker",
        "run",
        "--rm",
        "--tty",
        "--interactive",
        "--workdir",
        "/app",
        "-v",
        f"{scripts_dir}:/app/scripts:ro",
        image,
    ]
    # Add "python/bash" and potential options/flags
    cmd.extend(python_cmd)

    # Add the script and its arguments
    if script:
        cmd.extend([script] + args)

    return cmd


def run_docker(
    python_cmd: list[str], image: str, script: str, args: list, dryrun: bool
):
    cmd = construct_docker_command(image, python_cmd, script, args)

    if not dryrun:
        subprocess.run(cmd)
    else:
        print("[DRY] Cmd that would run: ", shlex.join(cmd))


def handle_arguments():
    parser = argparse.ArgumentParser(
        description="Run a Python script in a Docker container "
        "or an interactive shell if no script is provided"
    )
    parser.add_argument(
        "--image",
        default="python:3.12",
        help="Docker image to use (default: python:3.12)",
    )
    parser.add_argument(
        "--dryrun", action="store_true", help="Print the command without executing it"
    )
    parser.add_argument(
        "positional", nargs=argparse.REMAINDER, help="Script and its arguments"
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--interactive",
        action="store_true",
        help="Run Python in interactive mode (-i) after the script is done",
    )
    group.add_argument(
        "--bash",
        action="store_true",
        help="Run bash shell in the container instead of Python",
    )
    return parser.parse_args()


def main():
    args = handle_arguments()

    # Allow "python -i scripts/script.py"
    binary_cmd = ["python"] if not args.interactive else ["python", "-i"]
    binary_cmd = ["bash"] if args.bash else binary_cmd

    # The first positional argument is treated as the script
    if args.positional:
        script, *script_args = args.positional
    else:
        script, script_args = "", []

    run_docker(binary_cmd, args.image, script, script_args, args.dryrun)


if __name__ == "__main__":
    main()
