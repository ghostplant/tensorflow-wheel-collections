### Compile Native Tensorflow-GPU in Linux manually with Docker:
```sh
git clone https://github.com/ghostplant/tensorflow-cuda-optimized
cd tensorflow-cuda-optimized

CUDA_VERSION=9.2 CUDNN_VERSION=7.2 ./make-tensorflow1.10-ubuntu.sh
```
