# Tensorflow Serving Build S2I

## About

This S2I respository has [template](https://docs.openshift.org/latest/dev_guide/templates.html) files used for building tensorflow wheel files for:

- `Centos7`
- `Fedora28`
- `Fedora29`
- `Fedora30`
- `RHEL7.6`

TODO:

- `Fedora27`
- `RHEL7.5`

NOTE: for `RHEL7.5` you need a system with RHEL Subscription enabled.

### For CPU

The files created from these templates are available at [AICoE/tensorflow-wheels](https://github.com/AICoE/tensorflow-wheels/releases). And the instructions to use with pipfile are given here [AICoE's TensorFlow Artifacts](https://index-aicoe.a3c1.starter-us-west-1.openshiftapps.com/).

### For GPU: TODO

GPU is not yet supported.

## Bazel map with TensorFlow version

Bazel Version | Tensorflow version
------------- | ------------------
0.24.1        | 1.14
0.21.0        | 1.13
0.18.0        | 1.12

## Bazel build options

- `TF_NEED_JEMALLOC`: = 1
- `TF_NEED_GCP`: = 0
- `TF_NEED_VERBS`: = 0
- `TF_NEED_HDFS`: = 0
- `TF_ENABLE_XLA`: = 0
- `TF_NEED_OPENCL`: = 0
- `TF_NEED_CUDA`: = 1
- `TF_NEED_MPI`: = 0
- `TF_NEED_GDR`: = 0
- `TF_NEED_S3`: = 0
- `TF_CUDA_VERSION`: = 9.0
- `TF_CUDA_COMPUTE_CAPABILITIES`: = 3.0,3.5,5.2,6.0,6.1,7.0
- `TF_CUDNN_VERSION`: = 7
- `TF_NEED_OPENCL_SYCL`:= 0
- `TF_NEED_TENSORRT`:= 0
- `TF_CUDA_CLANG`:= 0
- `GCC_HOST_COMPILER_PATH`:= /usr/bin/gcc
- `CUDA_TOOLKIT_PATH`:= /usr/lib/cuda
- `CUDNN_INSTALL_PATH`:= /usr/lib/cuda
- `TF_NEED_KAFKA`:=0
- `TF_NEED_OPENCL_SYCL`:=0
- `TF_DOWNLOAD_CLANG`:=0
- `TF_SET_ANDROID_WORKSPACE`:=0
- `TF_NEED_IGNITE`: = 0
- `TF_NEED_ROCM`: = 0

Here is the default build command used to build tensorflow.

- `CUSTOM_BUILD`:=`bazel build -c opt --local_resources 2048,2.0,1.0 --verbose_failures //tensorflow_serving/model_servers:tensorflow_model_server`

- `CUSTOM_BUILD_2`:=`bazel build -c opt --local_resources 2048,2.0,1.0 --verbose_failures tensorflow_serving/tools/pip_package:build_pip_package`

Following should be left blank for a build job.

- `TEST_LOOP`:=
- `BUILD_OPTS`:=

## Usage

### To create a wheel file

_set some environment values for convenience_

```
# git token and repo
# valid values are 2.7,3.6,3.5
PYTHON_VERSION=3.6
GIT_TOKEN=
export GIT_RELEASE_REPO=
```

#### 1\. Create the templates

```
oc create -f tensorflow-build-image.json
oc create -f tensorflow-build-job.json
oc create -f tensorflow-build-dc.json
```

#### 2\. Create Tensorflow-Serving build image

```
oc new-app --template=tensorflow-serving-build-image  \
 --param=APPLICATION_NAME=tf-serving-fc29-build-image-${PYTHON_VERSION//.} \
 --param=S2I_IMAGE=registry.fedoraproject.org/f29/s2i-core   \
 --param=DOCKER_FILE_PATH=Dockerfile.fedora28 \
 --param=PYTHON_VERSION=$PYTHON_VERSION --param=BUILD_VERSION=1 --param=BAZEL_VERSION=0.21.0

oc new-app --template=tensorflow-serving-build-image  \
 --param=APPLICATION_NAME=tf-serving-centos7-build-image-${PYTHON_VERSION//.} \
 --param=S2I_IMAGE=openshift/base-centos7   \
 --param=DOCKER_FILE_PATH=Dockerfile.centos7 \
 --param=PYTHON_VERSION=$PYTHON_VERSION --param=BUILD_VERSION=1 --param=BAZEL_VERSION=0.21.0
```

The above command creates a tensorflow builder image `APPLICATION_NAME:VERSION` for specific OS.

The values for `S2I_IMAGE` are :

- Fedora28- `registry.fedoraproject.org/f28/s2i-core`
- Centos7- `openshift/base-centos7`

The values for `DOCKER_FILE_PATH` are :

- Fedora28- `Dockerfile.fedora28`
- Centos7- `Dockerfile.centos7`

#### 3\. Create Tensorflow wheel for CPU using the build image

```
oc new-app --template=tensorflow-serving-build-job  \
--param=APPLICATION_NAME=tf-serving-fc29-build-job-${PYTHON_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-fc29-build-image-${PYTHON_VERSION//.}:1  \
--param=PYTHON_VERSION=$PYTHON_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.21.0 --param=TF_GIT_BRANCH=r1.13 --param=CPU_LIMIT=36 --param=CPU_REQUESTS=36 --param=MEMORY_LIMIT=50Gi --param=MEMORY_REQUESTS=50Gi

oc new-app --template=tensorflow-serving-build-job  \
--param=APPLICATION_NAME=tf-serving-centos7-build-job-${PYTHON_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-centos7-build-image-${PYTHON_VERSION//.}:1  \
--param=PYTHON_VERSION=$PYTHON_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.21.0 --param=TF_GIT_BRANCH=r1.13 --param=CPU_LIMIT=36 --param=CPU_REQUESTS=36 --param=MEMORY_LIMIT=50Gi --param=MEMORY_REQUESTS=50Gi
```

_OR_

Import the template `tensorflow-build-job.json` into your namespace from Openshift UI. And then deploy from UI with appropriate values. Tensorflow wheel files will be pushed to `$GIT_RELEASE_REPO` using the token `$GIT_TOKEN`. (NOTE: This will ONLY work if the oauth token has scope of "repo". You can generate Personal API access token at <https://github.com/settings/tokens>. Minimal token scope is "repo".)

### To create a DEV environment for debugging build issues :

```
oc new-app --template=tensorflow-serving-build-dc  \
--param=APPLICATION_NAME=tf-serving-build-dc-fc28-${PYTHON_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-fc28-build-image-${PYTHON_VERSION//.}:1  \
--param=PYTHON_VERSION=$PYTHON_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.18.0 --param=TF_GIT_BRANCH=r1.12
```

NOTE: `BUILDER_IMAGESTREAM = APPLICATION_NAME:BUILD_VERSION` from step 2.
