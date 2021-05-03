
NOW=$(date '+%Y%m%dT%H%M%S')
CONFIGURATION_NAME="holanube-sagemaker-lifecycle-${NOW}"
echo $CONFIGURATION_NAME

# create new lifecycle configuration
aws sagemaker create-notebook-instance-lifecycle-config \
    --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME"

# add the code to auto-stop instance and persist conda enviroments.
echo '#!/bin/bash' > on-start.sh
echo 'set -e' >> on-start.sh
echo 'curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/auto-stop-idle/on-start.sh | bash' >> on-start.sh
echo 'curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/save-conda-enviroments/on-start.sh | bash' >> on-start.sh

# update the lifecycle configuration config with updated on-start.sh script
aws sagemaker update-notebook-instance-lifecycle-config \
    --notebook-instance-lifecycle-config-name "$CONFIGURATION_NAME" \
    --on-start Content="$((cat on-start.sh)| base64)"

aws iam create-role --path "/service-role/" \
--role-name AmazonSageMaker-ExecutionRole-${NOW} \
--assume-role-policy-document file://trustpolicy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole --role-name AmazonSageMaker-ExecutionRole-${NOW}
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess --role-name AmazonSageMaker-ExecutionRole-${NOW}
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name AmazonSageMaker-ExecutionRole-${NOW}
aws iam attach-role-policy --policy-arn arn:aws:iam::380245089291:policy/sagemaker-autostop --role-name AmazonSageMaker-ExecutionRole-${NOW}

INSTANCE_NAME="holanube-sagemaker-instance-${NOW}"
INSTANCE_TYPE="ml.t2.medium"
#ROLE_ARN="arn:aws:iam::380245089291:role/service-role/AmazonSageMaker-ExecutionRole-20210427T235849"
ROLE_ARN="arn:aws:iam::380245089291:role/service-role/AmazonSageMaker-ExecutionRole-${NOW}"

aws sagemaker create-notebook-instance \
    --notebook-instance-name "${INSTANCE_NAME}" \
    --instance-type "${INSTANCE_TYPE}" \
    --role-arn "${ROLE_ARN}" \
    --lifecycle-config-name "${CONFIGURATION_NAME}" \
    --volume-size-in-gb 20