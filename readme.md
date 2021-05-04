# Sagemaker : How to create a notebook instance with auto-stop and persist the Conda Enviroments

If you just started to use sagemaker, you are going to like to have an automatic way to turn off the instance to not worry about unexpected charges. The setup includes a modified [auto-stop-idle](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/tree/master/scripts/auto-stop-idle) script by Amazon. This script stops a SageMaker notebook once it's idle for more than 30 minutes (default time).

But also when you start again the notebook, you are going to realize that all the libraries you installed were gone. And that's annoying. So a way to persist your enviroments this setup creates a directory where all new created enviroments will be located and persist.

In order to create a sagemaker notebook instance with this initial setup run this code into the cloud shell:

```bash
git clone https://github.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities
cd aws-sagemaker-nb-it-utilities
bash main/awscli.sh
```

The shell script "awscli.sh" will going to make this steps:
1. Create a lifecycle configuration named "holanube-sagemaker-lifecycle-YYYYMMMDDThhmmss".
2. Add a on-start.sh file to lifecycle configuration.
3. Create a policy necessary by auto-stop script("sagemaker-autostop-YYYYMMMDDThhmmss").
4. Create a role named "AmazonSageMaker-ExecutionRole-YYYYMMMDDThhmmss"
5. Attach to the created role this policies:
    * AWSGlueServiceNotebookRole
    * AmazonSageMakerFullAccess
    * AmazonS3FullAccess
    * sagemaker-autostop-YYYYMMMDDThhmmss
6. Create a notebook instance with the created lifecycle configuration and created role.

The shell script "on-start.sh" attached to the lifecycle will download an execute this two shells:
1. auto-stop-idle/on-start.sh
2. save-conda-enviroments/on-start.sh

```bash
#!/bin/bash
set -e
curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/auto-stop-idle/on-start.sh | bash
curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/save-conda-enviroments/on-start.sh | bash
```
