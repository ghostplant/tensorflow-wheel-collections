#!/bin/bash -e

# You can change the driver version for compilation
CUDA_VERSION=${CUDA_VERSION:-9.2}
CUDNN_VERSION=${CUDNN_VERSION:-7.2}

WORKDIR=$(pwd)
cd $(mktemp -d)

cat <<EOF > Dockerfile
FROM nvidia/cuda:${CUDA_VERSION}-cudnn$(echo ${CUDNN_VERSION} | awk -F\. '{print $1}')-devel-ubuntu16.04
MAINTAINER CUI Wei <ghostplant@qq.com>

RUN apt update && apt install -y --no-install-recommends librdmacm-dev openjdk-8-jdk curl git vim-tiny less netcat-openbsd zlib1g-dev bash-completion g++ python3-setuptools python3-pip python3-wheel python3-numpy python3-dev && rm -rf /var/lib/apt/lists/*
RUN curl -Ls https://github.com/bazelbuild/bazel/releases/download/0.15.0/bazel_0.15.0-linux-x86_64.deb > bazel.deb && dpkg -i bazel.deb && rm bazel.deb
RUN cd root && git clone http://github.com/tensorflow/tensorflow --branch r1.10 --single-branch --depth 1
RUN ln -s python3 /usr/bin/python
RUN echo "/usr/local/cuda/targets/x86_64-linux/lib/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf && ldconfig
# RUN ln -s libdevice.compute_50.10.bc /usr/local/cuda/nvvm/libdevice/libdevice.10.bc

WORKDIR /root/tensorflow

# RUN sed -i 's/^#if TF_HAS_.*\$/#if !defined(__NVCC__)/g' tensorflow/core/platform/macros.h

# 1st Y: GDR; 2nd Y: CUDA; 
RUN /bin/echo -e "/usr/bin/python3\n\nN\nN\nN\nN\nN\nN\nY\nN\nN\nY\n${CUDA_VERSION}\n/usr/local/cuda\n${CUDNN_VERSION}\n/usr\nN\n1.3\n\nN\n\nN\n-march=native\nN\n" | ./configure
RUN bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
RUN rm -rf /root/tensorflow_pkg && bazel-bin/tensorflow/tools/pip_package/build_pip_package /root/tensorflow_pkg
EOF

WHEEL_NAME="tensorflow-1.10_cuda${CUDA_VERSION}_cudnn${CUDNN_VERSION}-cp35-cp35m-linux_x86_64.whl"

docker build --network host -t tensorflow .
docker run -it --rm -v ${WORKDIR}:/mnt tensorflow bash -c "cp ../tensorflow_pkg/*.whl /mnt/${WHEEL_NAME}"

echo "=========================================="
echo
echo "You can install the wheel package via:"
echo
echo "pip3 install ${WORKDIR}/${WHEEL_NAME}"
echo
