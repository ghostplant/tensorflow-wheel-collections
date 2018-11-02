__ops_fullname__ = 'main_ops'

package(default_visibility = ["//tensorflow:__subpackages__"])

load(
    "//tensorflow:tensorflow.bzl",
    "tf_custom_op_library",
    "tf_gen_op_libs",
    "tf_gen_op_wrapper_py",
    "tf_custom_op_py_library",
)

load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda")


tf_custom_op_library(
    name = "_lib_ops.so",
    srcs = [
        "ops/%s.cc" % __ops_fullname__,
    ],
    deps = if_cuda([
        "//tensorflow/core:gpu_headers_lib",
    ]),
)

tf_gen_op_libs(
    op_lib_names = [__ops_fullname__],
    deps = [
        "//tensorflow/core:lib",
    ],
)

tf_gen_op_wrapper_py(
    name = __ops_fullname__,
    deps = [":%s_op_lib" % __ops_fullname__],
)

tf_custom_op_py_library(
    name = "setup_py",
    srcs = [
        "__init__.py",
    ],
    kernels = [],
    deps = [
        ":" + __ops_fullname__,
        "//tensorflow/contrib/util:util_py",
        "//tensorflow/python:device",
        "//tensorflow/python:framework_ops",
        "//tensorflow/python:platform",
        "//tensorflow/python:util",
        "//tensorflow/python/eager:context",
    ],
    dso = [":_lib_ops.so"],
    visibility = ["//visibility:public"],
)
