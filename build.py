import os

def find_directory_and_file(directory, subdirectory, filename):
    for dir_path, dir_names, filenames in os.walk(directory):
        if subdirectory in dir_names:
            file_path = os.path.join(dir_path, subdirectory, filename)
            if os.path.exists(file_path):
                return file_path
    return None


def run_typst_link():
    link_cmd = "typst-ts-cli package link --manifest {0}".format(file_path)
    print("succeed to run cmd: {0}".format(link_cmd))
    os.system(link_cmd)



root_path = "/home/"

os.system("curl https://sh.rustup.rs -sSf | sh")
os.system("$HOME/.cargo/env")
os.system("cargo install --git https://github.com/Myriad-Dreamin/typst.ts typst-ts-cli")

file_path = find_directory_and_file(root_path, "variables", "typst.toml")
if file_path is None:
    print("failed to find files")
else:
    print("filed files in {0}".format(file_path))
    run_typst_link()



