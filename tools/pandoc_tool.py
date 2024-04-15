import os
import sys
import subprocess

pandoc_path = "c:\\Program Files\\Pandoc\\pandoc.exe"


def get_current_dir():
    return os.path.dirname(os.path.realpath(__file__))


def get_main_typst_file():
    path = os.path.join(get_current_dir(), '../main.typ')
    return os.path.abspath(path)



def convrt_typst_to_md(typst_file_path):
    output_dir = os.path.dirname(typst_file_path)
    file_name = os.path.basename(typst_file_path)
    output_file_name = os.path.join(output_dir, '{}.md'.format(file_name))

    if not os.path.exists(pandoc_path):
        print("failed to find pandoc: {}".format(pandoc_path))
        return

    print("try to convert {} to {}".format(typst_file_path, output_file_name))

    args = [
        "-f", "typst", "-t", "markdown", "-o", output_file_name, typst_file_path
    ]
    cmd = [pandoc_path] + args
    print("run pandoc with args: {}".format(cmd))

    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if (result.returncode != 0):
        print("pandoc result: {}".format(result.stdout.decode('utf-8')))
        print("pandoc error: {}".format(result.stderr.decode('utf-8')))
        print("pandoc return code: {}".format(result.returncode))
    else:
        print("succeed to convert {} to {}".format(typst_file_path, output_file_name))


def main(argv):
    main_file_path = get_main_typst_file()
    if (os.path.exists(main_file_path)):
        print("succeed to find main file: {}".format(main_file_path))
        convrt_typst_to_md(main_file_path)
    else:
        print("failed to find main file: {}".format(main_file_path))


if __name__ == '__main__':
    main(sys.argv)