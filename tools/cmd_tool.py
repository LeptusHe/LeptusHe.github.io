import subprocess
import os


def is_windows_platform():
    if os.name == 'nt':
        return True
    return False


def is_tool_installed_pipe(tool_and_args, use_pipe):
    try:
        if use_pipe:
            result = subprocess.run(tool_and_args, check=True, shell=True,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
            return [True, result]
        else:
            subprocess.run(tool_and_args, check=True, shell=True)
            return [True, ""]
    except subprocess.CalledProcessError as e:
        print(e.cmd, e.returncode, e.stderr)
        return [False, ""]


def is_tool_installed(tool_and_args):
    result, info = is_tool_installed_pipe(tool_and_args, False)
    return result


def check_tool_installed():
    print("typst exist: {0}" .format(is_tool_installed(["typst", "--version"])))
    print("typst exist: {0}" .format(is_tool_installed(["typst-ts-cli", "--version"])))
    print("typst exist: {0}" .format(is_tool_installed(["hexo", "--version"])))