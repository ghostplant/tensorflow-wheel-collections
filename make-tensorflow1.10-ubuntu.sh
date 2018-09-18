#!/bin/bash -e

# You can change the driver version for compilation
CUDA_VERSION=${CUDA_VERSION:-9.2}
CUDNN_VERSION=${CUDNN_VERSION:-7.2}
USING_NCCL2=${USING_NCCL2:-1}
CPU_ARCH=${CPU_ARCH:-x86-64}

if [ "x${USING_NCCL2}" = "x0" ]; then
	USING_NCCL2="1.3"
else
	USING_NCCL2="2.2\n/usr"
fi

WORKDIR=$(pwd)
cd $(mktemp -d)

cat <<EOF > Dockerfile
FROM nvidia/cuda:${CUDA_VERSION}-cudnn$(echo ${CUDNN_VERSION} | awk -F\. '{print $1}')-devel-ubuntu16.04
MAINTAINER CUI Wei <ghostplant@qq.com>

# RUN bash -c 'apt-key add <(curl -L http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/7fa2af80.pub)'
RUN echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list
RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

RUN apt update && apt install -y --no-install-recommends librdmacm-dev openjdk-8-jdk curl git vim-tiny less netcat-openbsd zlib1g-dev bash-completion g++ python3-setuptools python3-pip python3-wheel python3-numpy python3-dev libnccl2=2.2.13-1+cuda${CUDA_VERSION} libnccl-dev=2.2.13-1+cuda${CUDA_VERSION} && rm -rf /var/lib/apt/lists/*

RUN curl -Ls https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel_0.15.0-linux-x86_64.deb > bazel.deb && dpkg -i bazel.deb && rm bazel.deb
RUN cd root && git clone http://github.com/tensorflow/tensorflow --branch r1.10 --single-branch --depth 1
RUN ln -s python3 /usr/bin/python
RUN echo "/usr/local/cuda/targets/x86_64-linux/lib/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf && ldconfig
# RUN ln -s libdevice.compute_50.10.bc /usr/local/cuda/nvvm/libdevice/libdevice.10.bc
RUN ln -sf /usr/lib/x86_64-linux-gnu/libnccl.so.2.* /usr/lib/libnccl.so.2

WORKDIR /root/tensorflow

# RUN sed -i 's/^#if TF_HAS_.*\$/#if !defined(__NVCC__)/g' tensorflow/core/platform/macros.h

# 1st Y: GDR; 2nd Y: CUDA; 
RUN /bin/echo -e "/usr/bin/python3\n\nN\nN\nN\nN\nN\nN\nY\nN\nN\nY\n${CUDA_VERSION}\n/usr/local/cuda\n${CUDNN_VERSION}\n/usr\nN\n${USING_NCCL2}\n\nN\n\nN\n-march=${CPU_ARCH}\nN\n" | ./configure

# CUDA 8.0 Patch to reduce compat code
RUN if [ "${CUDA_VERSION}" = "8.0" ]; then sed -i '/capability.replace/a \ \ \ \ capability = "60" if capability == "70" else capability' third_party/gpus/crosstool/clang/bin/crosstool_wrapper_driver_is_not_gcc.tpl; fi

RUN bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
RUN rm -rf /root/tensorflow_pkg && bazel-bin/tensorflow/tools/pip_package/build_pip_package /root/tensorflow_pkg
EOF

WHEEL_NAME="tensorflow-1.10_cuda${CUDA_VERSION}_cudnn${CUDNN_VERSION}_nccl${USING_NCCL2:0:3}-cp35-cp35m-linux_x86_64.whl"

docker build --network host -t tensorflow .
docker run -it --rm -v ${WORKDIR}:/mnt tensorflow bash -c "cp ../tensorflow_pkg/*.whl /mnt/${WHEEL_NAME}"

echo "=========================================="
echo
echo "You can install the wheel package via:"
echo
echo "pip3 install ${WORKDIR}/${WHEEL_NAME}"
echo
