### Tensorflow-GPU prebuild binaries with Dockerfile for Linux + CUDA 8.0/9.0/9.2/10.0 which is not provided by official Tensorflow pip repository.

Prebuilt binaries (wheel format) download link: [download page](https://github.com/ghostplant/tensorflow-cuda-optimized/releases).

### Examples of Installation from online prebuilt binary:

```sh
# Install Tensorflow-GPU 1.10 on `Ubuntu 18.04 (Python 3.6)` with CUDA 10.0:
pip3 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda10.0_ubu1804-cp36-cp36m-linux_x86_64.whl

# Install Tensorflow-GPU 1.10 on `Ubuntu 16.04 (Python 3.5)` with CUDA 10.0:
pip3 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda10.0_ubu1604-cp35-cp35m-linux_x86_64.whl

# Install Tensorflow-GPU 1.10 on `Centos 7 (Python 2.7)` with CUDA 10.0:
pip2 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda10.0_centos7-cp27-cp27mu-linux_x86_64.whl

# Install Tensorflow-GPU 1.10 on `Ubuntu 16.04 (Python 3.5)` with CUDA 9.2:
pip3 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda9.2_ubu1604-cp35-cp35m-linux_x86_64.whl

# Install Tensorflow-GPU 1.10 on `Ubuntu 16.04 (Python 3.5)` with CUDA 9.0:
pip3 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda9.0_ubu1604-cp35-cp35m-linux_x86_64.whl

# Install Tensorflow-GPU 1.10 on `Ubuntu 16.04 (Python 3.5)` with CUDA 8.0:
pip3 install https://github.com/ghostplant/tensorflow-cuda-optimized/releases/download/tf-1.10-linux/tensorflow-1.10_cuda8.0_ubu1604-cp35-cp35m-linux_x86_64.whl
```


### How to Compile Tensorflow-GPU packages on Ubuntu from Source Code:

```sh
git clone https://github.com/ghostplant/tensorflow-cuda-optimized
cd tensorflow-cuda-optimized

# For example:

# Ubuntu 18.04 + CUDA 10.0 =>
REPO=1804 CUDA_VERSION=10.0 ./make-tensorflow1.10-ubuntu.sh

# Ubuntu 16.04 + CUDA 10.0 =>
REPO=1604 CUDA_VERSION=10.0 ./make-tensorflow1.10-ubuntu.sh

# Centos 7 + CUDA 10.0 =>
CUDA_VERSION=10.0 ./make-tensorflow1.10-centos7.sh

# Ubuntu 16.04 + CUDA 9.2 =>
REPO=1604 CUDA_VERSION=9.2 ./make-tensorflow1.10-ubuntu.sh

# Ubuntu 16.04 + CUDA 9.0 =>
REPO=1604 CUDA_VERSION=9.0 ./make-tensorflow1.10-ubuntu.sh

# Ubuntu 16.04 + CUDA 8.0 =>
REPO=1604 CUDA_VERSION=8.0 ./make-tensorflow1.10-ubuntu.sh

# Centos 7 + CUDA 8.0 =>
CUDA_VERSION=8.0 ./make-tensorflow1.10-centos7.sh
```
