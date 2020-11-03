import os
import sys

import imageio


def get_files(inpath):
    files = []
    for f in os.listdir(inpath):
        files.append(os.path.join(inpath, f))
    files.sort()
    return files


def make_mp4(inpath, outfile):
    filenames = get_files(inpath)
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    imageio.mimsave(outfile, images)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: imgtomp4 <inpath/> <out.mp4>")
    make_mp4(sys.argv[1], sys.argv[2])
