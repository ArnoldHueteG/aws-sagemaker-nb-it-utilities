#!/usr/bin/env bash

set -e

PERSISTED_CONDA_DIR="${PERSISTED_CONDA_DIR:-/home/ec2-user/SageMaker/.persisted_conda}"

echo "Setting up persisted conda environments..."
mkdir -p ${PERSISTED_CONDA_DIR} && chown ec2-user:ec2-user ${PERSISTED_CONDA_DIR}

envdirs_clean=$(grep "envs_dirs:" /home/ec2-user/.condarc || echo "clean")
if [[ "${envdirs_clean}" != "clean" ]]; then
    echo 'envs_dirs config already exists in /home/ec2-user/.condarc. No idea what to do. Exiting!'
    exit 1
fi

echo "Adding ${PERSISTED_CONDA_DIR} to list of conda env locations"
cat << EOF >> /home/ec2-user/.condarc
envs_dirs:
  - ${PERSISTED_CONDA_DIR}
  - /home/ec2-user/anaconda3/envs
EOF
echo "Adding ${PERSISTED_CONDA_DIR} to jupyter"
sudo -u ec2-user -i <<'EOF'
# To be executed at each start-up to ensure replication of conda envs in Conda & in Jupyter
if [ -d "/home/ec2-user/SageMaker/.persisted_conda" ]; then
  for env in ~/SageMaker/.persisted_conda/*/; do
  echo $env
# Exporting conda env to Jupyter Notebook kernel
  if [ -d "$env" ]; then
    python -m ipykernel install --user --name $(basename "$env") --display-name "$(basename "$env")"
  fi
done
fi
EOF