import os
import shutil

from tools.cmd_tool import *

typst_ts_cli_version = "0.4.1"


def find_directory_and_file(directory, subdirectory, filename):
    for dir_path, dir_names, filenames in os.walk(directory):
        if subdirectory in dir_names:
            file_path = os.path.join(dir_path, subdirectory, filename)
            if os.path.exists(file_path):
                return file_path
    return None


def install_cargo():
    if is_tool_installed('cargo --version'):
        print('cargo installed')
        return True

    if is_windows_platform():
        print("please install cargo")
        raise SystemExit(1)
    else:
        # install cargo on linux/unix platform
        # references: https://doc.rust-lang.org/cargo/getting-started/installation.html
        os.system("curl https://sh.rustup.rs -sSf | sh")
        os.system("$HOME/.cargo/env")
        return True


def install_typst():
    if is_tool_installed('typst --version'):
        print("typst installed")
        return
    else:
        print('try to install typst')
        os.system("cargo install --git https://github.com/typst/typst")


def download_typst_ts_cli(version):
    # install typst-ts-cli version v0.4.1
    os.system(
        f"cargo install --git https://github.com/Myriad-Dreamin/typst.ts typst-ts-cli --tag v0.4.1 --version ${version}")


def install_typst_ts_cli():
    exist, result = is_tool_installed_pipe('typst-ts-cli --version', True)
    if exist:
        version = result.stdout.decode().split()[2]

        if version != typst_ts_cli_version:
            print(f"typst-ts-cli version ${version} is not valid, please install new version is ${typst_ts_cli_version}")
            download_typst_ts_cli(typst_ts_cli_version)
        else:
            print(f"typst-ts-cli {version} installed")
    else:
        download_typst_ts_cli(typst_ts_cli_version)


def get_root_path():
    if is_windows_platform():
        print('running on windows platform')
        return os.path.expanduser("~")
    else:
        root_path = "/home/"
        return root_path


def run_typst_link(file_path):
    link_cmd = "typst-ts-cli package link --manifest {0}".format(file_path)
    print("succeed to run cmd: {0}".format(link_cmd))
    os.system(link_cmd)


def link_typst_cli_variables():
    root_path = get_root_path()
    file_path = find_directory_and_file(root_path, "variables", "typst.toml")
    if file_path is None:
        print("failed to find files")
        return False
    else:
        print("filed files in {0}".format(file_path))
        run_typst_link(file_path)
        return True


def run_hexo_generate():
    os.system("hexo clean")
    os.system("hexo generate")


def get_current_dir():
    return os.path.dirname(os.path.realpath(__file__))

def deploy(sub_dir):
    def clone():
        if os.path.exists(os.path.join(sub_dir, "LeptusHe.github.io")):
            print("git repository exist")
            return

        git_repo = "https://github.com/LeptusHe/LeptusHe.github.io.git"
        if not os.path.exists(sub_dir):
            print("creating subdir: {0}".format(sub_dir))
            os.mkdir(sub_dir)
        os.chdir(sub_dir)
        os.system("git clone {0}".format(git_repo))
        os.chdir("LeptusHe.github.io")
        os.system("git checkout gh-pages")

    def copy_public_dir():
        cur_dir = get_current_dir()
        src_dir = os.path.join(cur_dir, "public")
        dst_dir = os.path.join(cur_dir, "build/LeptusHe.github.io")

        # copy files and directory from src_dir to publish_dir
        shutil.copytree(src_dir, dst_dir, dirs_exist_ok=True)
        print("copy publish dir [{0}] to [{1}]".format(src_dir, dst_dir))

    clone()
    copy_public_dir()


def main():
    install_cargo()
    install_typst()
    install_typst_ts_cli()
    #run_hexo_generate()
    deploy('build2')


if __name__ == "__main__":
    main()

