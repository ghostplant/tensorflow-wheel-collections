### Provide Tensorflow-GPU builds for some CUDA versions not provided by official Tensorflow repo.

The list of all wheel-format downloads can be found in the [releases page](https://github.com/ghostplant/tensorflow-cuda8-cudnn6/releases).

### Compile Native Tensorflow-GPU:
```sh
git clone https://github.com/ghostplant/tensorflow-cuda8-optimized
cd tensorflow-cuda8-optimized
# Compile the source code of Tensorflow
docker build . -t tf1.8-py3-cuda8-cudnn6 -f Dockerfile.tf18-py35-cuda8-cudnn6021-ubuntu
# Copy the wheel package from inside docker container
docker run -it --rm -v `pwd`:/mnt tf1.8-py3-cuda8-cudnn6 bash -c 'cp ../tensorflow_pkg/*.whl /mnt'
# Setup package on physical host
pip3 install ./*.whl
```

### Examples of Installation from prebuilt binary:

Install Tensorflow-GPU 1.8 on Ubuntu 16.04 with CUDA driver 8.0 and CUDNN 7.1 and Python 3.5:
```sh
pip3 install https://github.com/ghostplant/tensorflow-cuda8-optimized/releases/download/tf1.8-py35-cuda8-cudnn71/tensorflow-1.8.0-cp35-cp35m-linux_x86_64.whl
```

Install Tensorflow-GPU 1.8 on Centos7 with CUDA driver 8.0 and CUDNN 6.0 and Python 2.7:
```sh
pip2 install https://github.com/ghostplant/tensorflow-cuda8-optimized/releases/download/tf1.8-py27-cuda8-cudnn6-centos7/tensorflow-1.8.0-cp27-cp27mu-linux_x86_64.whl
```
