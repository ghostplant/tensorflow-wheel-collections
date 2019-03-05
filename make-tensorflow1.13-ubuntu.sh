#!/bin/bash -e

# You can change the driver version for compilation
CUDA_VERSION=${CUDA_VERSION:-10.0}
CUDNN_VERSION=${CUDNN_VERSION:-7}
CPU_ARCH=${CPU_ARCH:-x86-64}
# REPO=${REPO:-$(grep DISTRIB_RELEASE /etc/lsb-release | awk -F'[=|.]' '{print $(NF-1)$(NF)}')}
REPO=${REPO:-1604}

[ "${CUDA_VERSION}" = "8.0" ] && echo "Tensorflow 1.13 for CUDA 8.0 is not supported." && exit 1

WORKDIR=$(pwd)
cd $(mktemp -d)

if [ "x$REPO" = "x1604" ]; then
	PYVER=35
elif [ "x$REPO" = "x1804" ]; then
	PYVER=36
else
	echo "Only 16.04 or 18.04 is supported for Ubuntu Linux."
	exit 1
fi
WHEEL_NAME="tensorflow-1.13_cuda${CUDA_VERSION}_ubu${REPO}-cp${PYVER}-cp${PYVER}m-linux_x86_64.whl"

cat <<EOF > Dockerfile
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${REPO:0:2}.${REPO:2}
MAINTAINER CUI Wei <ghostplant@qq.com>

# RUN bash -c "apt-key add <(curl -L http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu${REPO}/x86_64/7fa2af80.pub)"
RUN echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu${REPO}/x86_64 /" > /etc/apt/sources.list.d/cuda.list
RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu${REPO}/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

RUN apt update && apt install -y --no-install-recommends --allow-change-held-packages zip unzip librdmacm-dev openjdk-8-jdk curl git vim-tiny less netcat-openbsd zlib1g-dev bash-completion g++ python3-setuptools python3-pip python3-wheel python3-numpy python3-dev libnccl2 libnccl-dev && rm -rf /var/lib/apt/lists/*

RUN curl -Ls https://github.com/bazelbuild/bazel/releases/download/0.19.2/bazel_0.19.2-linux-x86_64.deb > bazel.deb && dpkg -i bazel.deb && rm bazel.deb
RUN cd root && git clone http://github.com/tensorflow/tensorflow --branch r1.13 --single-branch --depth 1
RUN ln -s python3 /usr/bin/python
RUN echo "/usr/local/cuda/targets/x86_64-linux/lib/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf && ldconfig
# RUN ln -s libdevice.compute_50.10.bc /usr/local/cuda/nvvm/libdevice/libdevice.10.bc
RUN ln -sf /usr/lib/x86_64-linux-gnu/libnccl.so.2.* /usr/lib/libnccl.so.2
RUN pip3 install keras==2.2.4 && rm -rf /root/.cache

WORKDIR /root/tensorflow

ENV PYTHON_BIN_PATH=/usr/bin/python3
ENV TF_ENABLE_XLA=0
ENV TF_NEED_OPENCL_SYCL=0
ENV TF_NEED_ROCM=0
ENV TF_NEED_CUDA=1
ENV TF_NEED_MPI=0
ENV TF_NEED_TENSORRT=0
ENV TF_CUDA_VERSION=${CUDA_VERSION}
ENV CUDA_TOOLKIT_PATH=/usr/local/cuda
ENV TF_CUDNN_VERSION=${CUDNN_VERSION}
ENV CUDNN_INSTALL_PATH=/usr
ENV TF_NCCL_VERSION=2
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,6.0,7.0
ENV TF_CUDA_CLANG=0
ENV GCC_HOST_COMPILER_PATH=/usr/bin/gcc
ENV CC_OPT_FLAGS="-march=${CPU_ARCH} -Wno-sign-compare"
ENV TF_SET_ANDROID_WORKSPACE=0

RUN ./configure

RUN bazel build --config=opt --config=cuda --cxxopt="-g" --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" //tensorflow/tools/pip_package:build_pip_package --verbose_failures
RUN rm -rf /root/tensorflow_pkg && bazel-bin/tensorflow/tools/pip_package/build_pip_package /root/tensorflow_pkg
RUN ls /root/tensorflow_pkg && mv /root/tensorflow_pkg/tensorflow-*.whl /root/tensorflow_pkg/${WHEEL_NAME}

# Packing libcudnn into tensorflow wheel:
RUN cd /root/tensorflow_pkg && unzip ${WHEEL_NAME} >/dev/null && rm ${WHEEL_NAME} && cp /usr/lib/x86_64-linux-gnu/libcudnn.so.${CUDNN_VERSION} tensorflow-*.data/purelib/tensorflow/python/ && cp /usr/include/x86_64-linux-gnu/cudnn_v${CUDNN_VERSION}.h tensorflow-*.data/purelib/tensorflow/include/ && zip -r /root/${WHEEL_NAME} * >/dev/null && rm -rf * && mv /root/${WHEEL_NAME} .
EOF


docker build --network host -t tensorflow .
docker run -it --rm -v ${WORKDIR}:/mnt tensorflow bash -c "cp /root/tensorflow_pkg/${WHEEL_NAME} /mnt"

cd "${WORKDIR}"

echo "=========================================="
echo
echo "You can install the wheel package via:"
echo
echo "pip3 install ./${WHEEL_NAME}"
echo
