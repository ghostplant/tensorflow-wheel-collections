### Compile native Tensorflow-GPU packages from Source Code under Linux with native CUDA/CUDNN driver versions:
```sh
git clone https://github.com/ghostplant/tensorflow-cuda-optimized
cd tensorflow-cuda-optimized

e.g.
CUDA_VERSION=9.2 CUDNN_VERSION=7.2 ./make-tensorflow1.10-ubuntu.sh

CUDA_VERSION=9.0 CUDNN_VERSION=7.0 ./make-tensorflow1.10-ubuntu.sh

CUDA_VERSION=8.0 CUDNN_VERSION=6.0 ./make-tensorflow1.10-ubuntu.sh
```
