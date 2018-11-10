#!/bin/bash -e

# You can change the driver version for compilation
CUDA_VERSION=${CUDA_VERSION:-10.0}
CUDNN_VERSION=${CUDNN_VERSION:-7}
USING_NCCL2=${USING_NCCL2:-1}
CPU_ARCH=${CPU_ARCH:-x86-64}

USING_NCCL2="1.3"  # "2.2\n/usr"

REPO=7
WORKDIR=$(pwd)
cd $(mktemp -d)

WHEEL_NAME="tensorflow-1.10_cuda${CUDA_VERSION}_centos${REPO}-cp27-cp27mu-linux_x86_64.whl"

cat <<EOF > Dockerfile
FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-centos${REPO}
MAINTAINER CUI Wei <ghostplant@qq.com>

RUN curl -L https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-${REPO}/vbatts-bazel-epel-${REPO}.repo > /etc/yum.repos.d/vbatts-bazel-epel-${REPO}.repo
RUN yum -y install bazel git which numpy patch python-devel librdmacm rdma-core-devel zip unzip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py && pip install mock enum34

RUN cd root && git clone http://github.com/tensorflow/tensorflow --branch r1.10 --single-branch --depth 1
RUN echo "/usr/local/cuda/targets/x86_64-linux/lib/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf && ldconfig
# RUN ln -sf /usr/lib/x86_64-linux-gnu/libnccl.so.2.* /usr/lib/libnccl.so.2

RUN ln -sf /usr/local/cuda/targets/x86_64-linux/include/cudnn.h /usr/include/cudnn_v${CUDNN_VERSION}.h
RUN ln -sf /usr/local/cuda/targets/x86_64-linux/include/cudnn.h /usr/include/cudnn.h

WORKDIR /root/tensorflow

RUN /bin/echo -e "/usr/bin/python\n\nN\nN\nN\nN\nN\nN\nY\nN\nN\nY\n${CUDA_VERSION}\n/usr/local/cuda\n${CUDNN_VERSION}.0\n/usr\nN\n${USING_NCCL2}\n\nN\n\nN\n-march=${CPU_ARCH}\nN\n" | ./configure

# CUDA 8.0 Patch to reduce compat code
RUN if [ "${CUDA_VERSION}" = "8.0" ]; then sed -i '/capability.replace/a \ \ \ \ capability = "60" if capability == "70" else capability' third_party/gpus/crosstool/clang/bin/crosstool_wrapper_driver_is_not_gcc.tpl; fi

RUN bazel build --config=opt --config=cuda --config=mkl --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" //tensorflow/tools/pip_package:build_pip_package
RUN rm -rf /root/tensorflow_pkg && bazel-bin/tensorflow/tools/pip_package/build_pip_package /root/tensorflow_pkg

RUN cd /root/tensorflow_pkg && ls tensorflow-1.10*.whl && unzip tensorflow-1.10*.whl >/dev/null && rm tensorflow-1.10*.whl && cp /usr/local/cuda/targets/x86_64-linux/lib/libcudnn.so.${CUDNN_VERSION} tensorflow-*.data/purelib/tensorflow/python/ && cp /usr/include/cudnn_v${CUDNN_VERSION}.h tensorflow-*.data/purelib/tensorflow/include/ && zip -r /root/${WHEEL_NAME} * >/dev/null && rm -rf *
EOF


docker build --network host -t tensorflow .
docker run -it --rm -v ${WORKDIR}:/mnt tensorflow bash -c "cp /root/${WHEEL_NAME} /mnt"

cd "${WORKDIR}"

echo "=========================================="
echo
echo "You can install the wheel package via:"
echo
echo "pip2 install ./${WHEEL_NAME}"
echo
