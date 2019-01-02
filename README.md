# Tensorflow Serving Build S2I

## About

This S2I respository has [template](https://docs.openshift.org/latest/dev_guide/templates.html) files used for building tensorflow wheel files for:
* `Centos7`
* `Fedora28`

TODO:
* `Fedora27`
* `RHEL7.5`
NOTE: for `RHEL7.5` you need a system with RHEL Subscription enabled.

##### For CPU 
The files created from these templates are available at [AICoE/tensorflow-wheels](https://github.com/AICoE/tensorflow-wheels/releases).
And the instructions to use with pipfile are given here [AICoE's TensorFlow Artifacts](https://index-aicoe.a3c1.starter-us-west-1.openshiftapps.com/).

##### For GPU: TODO
GPU is not yet supported.




## Usage

```
PYTH_VERSION=3.6
GIT_TOKEN=4549d22310051ec555b12427bfdc5cde5ccaa945
```

```
oc new-app --template=tensorflow-serving-build-image  \
--param=APPLICATION_NAME=tf-serving-build-image-centos7-${PYTH_VERSION//.} \
--param=S2I_IMAGE=openshift/base-centos7   \
--param=DOCKER_FILE_PATH=Dockerfile.centos7 \
--param=PYTHON_VERSION=$PYTH_VERSION --param=BUILD_VERSION=1
```

```
oc new-app --template=tensorflow-serving-build-job  \
--param=APPLICATION_NAME=tf-serving-build-job-centos7-${PYTH_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-build-image-centos7-${PYTH_VERSION//.}:1  \
--param=PYTHON_VERSION=$PYTH_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.15.0 --param=TF_GIT_BRANCH=r1.10
```


```
oc new-app --template=tensorflow-serving-build-image  \
--param=APPLICATION_NAME=tf-serving-build-image-fedora28-${PYTH_VERSION//.} \
--param=S2I_IMAGE=registry.fedoraproject.org/f28/s2i-core   \
--param=DOCKER_FILE_PATH=Dockerfile.fedora28 --param=PYTHON_VERSION=$PYTH_VERSION --param=BUILD_VERSION=1
```

```
oc new-app --template=tensorflow-serving-build-job  \
--param=APPLICATION_NAME=tf-serving-build-job-fedora28-${PYTH_VERSION//.} \
--param=BUILDER_IMAGESTREAM=tf-serving-build-image-fedora28-${PYTH_VERSION//.}:1  \
--param=PYTHON_VERSION=$PYTH_VERSION     --param=GIT_TOKEN=$GIT_TOKEN \
--param=BAZEL_VERSION=0.15.0 --param=TF_GIT_BRANCH=r1.10
```

