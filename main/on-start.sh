#!/bin/bash
set -e
# add the code to auto-stop instance and persist conda enviroments.
curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/auto-stop-idle/on-start.sh | bash
curl https://raw.githubusercontent.com/ArnoldHueteG/aws-sagemaker-nb-it-utilities/master/save-conda-enviroments/on-start.sh | bash