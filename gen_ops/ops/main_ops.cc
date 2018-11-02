/**************** Tensorflow Ops ****************

[bzl::config]
OPS_NAME=__ops_workdir__
awk -i "/.*if_cuda\(/{print; print \"'//tensorflow/contrib/${OPS_NAME}:setup_py',\"; next}1" tensorflow/contrib/BUILD

[e.g.]
from tensorflow.contrib.__ops_workdir__.ops import gen_main_ops
out = gen_main_ops.compute_async(input=[2, 4], num_devices=3)

*/

#include "tensorflow/core/framework/common_shape_fns.h"
#include "tensorflow/core/framework/op.h"

#include "tensorflow/core/common_runtime/gpu/gpu_event_mgr.h"
#include "tensorflow/core/framework/tensor.h"
#include "tensorflow/core/platform/mutex.h"
#include "tensorflow/core/platform/stream_executor.h"

#include "tensorflow/core/lib/core/threadpool.h"
#include "tensorflow/core/platform/cuda.h"
#include "tensorflow/core/platform/env.h"

#include "tensorflow/core/framework/op_kernel.h"
#include <cuda_runtime_api.h>

#define OPS_NAME "ComputeAsync"
#define CLASS_NAME ComputeAsyncOpKernel


namespace tensorflow {


class CLASS_NAME : public AsyncOpKernel {
 public:
  explicit CLASS_NAME(OpKernelConstruction* c)
      : AsyncOpKernel(c) {
    OP_REQUIRES_OK(c, c->GetAttr("num_devices", &num_devices_));
    printf("Construct ComputeAsyncOpKernel.\n");
  }

  ~CLASS_NAME() {
    printf("Deconstruct ComputeAsyncOpKernel.\n");
  }

  void ComputeAsync(OpKernelContext* c, DoneCallback done) override {
    const Tensor* in_t = &c->input(0);
    Tensor* out_t = nullptr;
    auto out_shape = in_t->shape(); // tensorflow::TensorShape({3, 4})
    OP_REQUIRES_OK_ASYNC(c, c->allocate_output(0, out_shape, &out_t), done);

    auto* gpu_info = c->device()->tensorflow_gpu_device_info();
    EventMgr* event_mgr = gpu_info->event_mgr;
    se::Stream* tensor_stream = c->op_device_context()->stream();
    se::StreamExecutor* executor = tensor_stream->parent();
    const cudaStream_t* cu_stream = reinterpret_cast<const cudaStream_t*>(
      tensor_stream->implementation()->CudaStreamMemberHack());

    auto res = cudaMemsetAsync((void*)out_t->tensor_data().data(), 0x50, out_t->NumElements() * sizeof(float), *cu_stream);
    if (res != cudaSuccess)
      abort();
    printf("num_dev = %d, gpu_id = %d, res = %d, matchFloat = %d.\n", num_devices_, gpu_info->gpu_id, res, DT_FLOAT == in_t->dtype());
    done();
  }

 private:
  int num_devices_;
  TF_DISALLOW_COPY_AND_ASSIGN(CLASS_NAME);
};

REGISTER_KERNEL_BUILDER(Name(OPS_NAME).Device(DEVICE_GPU), CLASS_NAME);

REGISTER_OP(OPS_NAME)
    .Input("input: T")
    .Output("data: T")
    .Attr("T: {half, float, float64, int32, int64}")
    .Attr("num_devices: int")
    .SetIsStateful()
    .SetShapeFn(shape_inference::UnknownShape);

}  // namespace tensorflow
