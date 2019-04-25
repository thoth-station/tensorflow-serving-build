# Kubeflow compatible Tensorflow Serving Images


### Build Tensorflow Serving Images
```
docker build -f Dockerfile.centos7  -t submod/tf_serving_centos7_1.9 .
docker build -f Dockerfile.fedora28  -t submod/tf_serving_f28_1.10 .
docker push submod/tf_serving_centos7_1.9
docker push submod/tf_serving_f28_1.10 

docker build -f Dockerfile.centos7  -t quay.io/sub_mod/aicoe/tf_serving_centos7_1.9 .
docker build -f Dockerfile.fedora28  -t quay.io/aicoe/tf_serving_f28_1.10 .
docker push quay.io/aicoe/aicoe/tf_serving_centos7_1.9
docker push quay.io/aicoe/tf_serving_f28_1.10 
```
Images are located here 
https://hub.docker.com/_/fedora/ 
https://hub.docker.com/_/centos/ 
https://console.cloud.google.com/storage/browser/kubeflow-models/inception/1/ 


### Use Tensorflow Serving Images
```
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: tf-serving
  name: tf-serving
spec:
  template:
    metadata:
      labels:
        app: tf-serving
        version: v1
    spec:
      containers:
      - image: submod/tf_serving_centos7_1.9
        imagePullPolicy: IfNotPresent
        name: tf-serving
        args:
        - --port=9000
        - --rest_api_port=8500
        - --model_name=mnist
        - --model_base_path=s3://kubeflow/inception/export
#        - --monitoring_config_file=/var/config/monitoring_config.txt
        command:
        - /usr/bin/tensorflow_model_server
        env:
        - name: AWS_ACCESS_KEY_ID
          value: minio
        - name: AWS_SECRET_ACCESS_KEY
          value: minio123
        - name: AWS_REGION
          value: us-west-1
        - name: S3_REGION
          value: us-east-1
        - name: S3_USE_HTTPS
          value: "0"
        - name: S3_VERIFY_SSL
          value: "0"
        - name: S3_ENDPOINT
          value: minio-service.kubeflow.svc:9000
        - name: TF_CPP_MIN_LOG_LEVEL
          value: "1"
        livenessProbe:
          initialDelaySeconds: 30
          periodSeconds: 30
          tcpSocket:
            port: 9000
        ports:
        - containerPort: 9000
        - containerPort: 8500
        resources:
          limits:
            cpu: "4"
            memory: 4Gi

```

### FAQs

Q:I see below error between client and serving endpoint.What is the issue?
```
Check whether your GraphDef-interpreting binary is up to date with your GraphDef-generating binary
```
A: This is due to difference in the tensorflow binary used in training and the serving binary used for serving.


### Test Tensorflow Serving Images you built.
```
docker run -it -v $PWD:/models/ -e MODEL_NAME=mnist submod/tf_serving_centos7_1.9  
```

```
$ docker run -it -v $PWD:/models/ -e MODEL_NAME=mnist submod/tf_serving_centos7_1.9 
total 8
-rw-r--r-- 1 root root 1643 Jan 21 17:37 Dockerfile.centos7
-rw-r--r-- 1 root root  144 Jan 21 17:35 README.md
drwxr-xr-x 3 root root  102 Jan 21 17:33 mnist
2019-01-21 17:39:32.686838: I tensorflow_serving/model_servers/main.cc:153] Building single TensorFlow model file config:  model_name: mnist model_base_path: /models/mnist
2019-01-21 17:39:32.687202: I tensorflow_serving/model_servers/server_core.cc:459] Adding/updating models.
2019-01-21 17:39:32.687227: I tensorflow_serving/model_servers/server_core.cc:514]  (Re-)adding model: mnist
2019-01-21 17:39:32.799726: I tensorflow_serving/core/basic_manager.cc:716] Successfully reserved resources to load servable {name: mnist version: 1}
2019-01-21 17:39:32.799779: I tensorflow_serving/core/loader_harness.cc:66] Approving load for servable version {name: mnist version: 1}
2019-01-21 17:39:32.799791: I tensorflow_serving/core/loader_harness.cc:74] Loading servable version {name: mnist version: 1}
2019-01-21 17:39:32.800169: I external/org_tensorflow/tensorflow/contrib/session_bundle/bundle_shim.cc:360] Attempting to load native SavedModelBundle in bundle-shim from: /models/mnist/1
2019-01-21 17:39:32.800598: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:242] Loading SavedModel with tags: { serve }; from: /models/mnist/1
2019-01-21 17:39:32.804413: I external/org_tensorflow/tensorflow/core/platform/cpu_feature_guard.cc:141] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
2019-01-21 17:39:32.816136: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:161] Restoring SavedModel bundle.
2019-01-21 17:39:32.826021: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:196] Running LegacyInitOp on SavedModel bundle.
2019-01-21 17:39:32.829735: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:291] SavedModel load for tags { serve }; Status: success. Took 29506 microseconds.
2019-01-21 17:39:32.830265: I tensorflow_serving/servables/tensorflow/saved_model_warmup.cc:83] No warmup data file found at /models/mnist/1/assets.extra/tf_serving_warmup_requests
2019-01-21 17:39:32.843163: I tensorflow_serving/core/loader_harness.cc:86] Successfully loaded servable version {name: mnist version: 1}
2019-01-21 17:39:32.845195: I tensorflow_serving/model_servers/main.cc:323] Running ModelServer at 0.0.0.0:8500 ...
2019-01-21 17:39:32.846263: I tensorflow_serving/model_servers/main.cc:333] Exporting HTTP/REST API at:localhost:8501 ...
[evhttp_server.cc : 235] RAW: Entering the event loop ...

```


```
$ docker run -it -v $PWD:/models/ -e MODEL_NAME=mnist submod/tf_serving_f28_1.10 
total 16
-rw-r--r-- 1 root root 1643 Jan 21 17:37 Dockerfile.centos7
-rw-r--r-- 1 root root 1645 Jan 21 17:47 Dockerfile.fedora28
-rw-r--r-- 1 root root 4495 Jan 21 17:50 README.md
drwxr-xr-x 3 root root  102 Jan 21 17:33 mnist
2019-01-21 17:51:11.744947: I tensorflow_serving/model_servers/main.cc:157] Building single TensorFlow model file config:  model_name: mnist model_base_path: /models/mnist
2019-01-21 17:51:11.745188: I tensorflow_serving/model_servers/server_core.cc:462] Adding/updating models.
2019-01-21 17:51:11.745232: I tensorflow_serving/model_servers/server_core.cc:517]  (Re-)adding model: mnist
2019-01-21 17:51:11.857623: I tensorflow_serving/core/basic_manager.cc:739] Successfully reserved resources to load servable {name: mnist version: 1}
2019-01-21 17:51:11.857684: I tensorflow_serving/core/loader_harness.cc:66] Approving load for servable version {name: mnist version: 1}
2019-01-21 17:51:11.857697: I tensorflow_serving/core/loader_harness.cc:74] Loading servable version {name: mnist version: 1}
2019-01-21 17:51:11.858026: I external/org_tensorflow/tensorflow/contrib/session_bundle/bundle_shim.cc:360] Attempting to load native SavedModelBundle in bundle-shim from: /models/mnist/1
2019-01-21 17:51:11.858061: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:31] Reading SavedModel from: /models/mnist/1
2019-01-21 17:51:11.861382: I external/org_tensorflow/tensorflow/cc/saved_model/reader.cc:54] Reading meta graph with tags { serve }
2019-01-21 17:51:11.862062: I external/org_tensorflow/tensorflow/core/platform/cpu_feature_guard.cc:141] Your CPU supports instructions that this TensorFlow binary was not compiled to use: SSE4.1 SSE4.2 AVX AVX2 FMA
2019-01-21 17:51:11.871454: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:113] Restoring SavedModel bundle.
2019-01-21 17:51:11.880978: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:148] Running LegacyInitOp on SavedModel bundle.
2019-01-21 17:51:11.884149: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:233] SavedModel load for tags { serve }; Status: success. Took 26077 microseconds.
2019-01-21 17:51:11.884544: I tensorflow_serving/servables/tensorflow/saved_model_warmup.cc:83] No warmup data file found at /models/mnist/1/assets.extra/tf_serving_warmup_requests
2019-01-21 17:51:11.891735: I tensorflow_serving/core/loader_harness.cc:86] Successfully loaded servable version {name: mnist version: 1}
2019-01-21 17:51:11.898068: I tensorflow_serving/model_servers/main.cc:327] Running ModelServer at 0.0.0.0:8500 ...
2019-01-21 17:51:11.898895: I tensorflow_serving/model_servers/main.cc:337] Exporting HTTP/REST API at:localhost:8501 ...
[evhttp_server.cc : 235] RAW: Entering the event loop ...
```