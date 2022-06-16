FROM node:alpine

# Copy Python requirements.txt file onto the image.
COPY python-requirements.txt .

# Install AWS CLI, jq and CA certificates
RUN apk -v --update add \
    python3 \
    py-pip \
    groff \
    less \
    mailcap \
    jq \
    ca-certificates \
    git \
    build-base \
    openssl-dev \
    gettext \
    bash \
    curl \
    && \
    pip install --upgrade -r python-requirements.txt && \
    pip freeze && \
    rm /var/cache/apk/*

# Install `cfn-create-or-update`, `@fountainhead/branch-officer`,
# `@fountainhead/helmfile-cleanup` and clear npm cache to reduce image size
RUN npm install -g cfn-create-or-update \
    @fountainhead/branch-officer@2.0.0 \
    @fountainhead/helmfile-cleanup@1.0.1 \
    && \
    npm cache clean --force

# Install kubectl, AWS IAM Authenticator, AWS ECR Credential Helper, Helm client, Helmfile and Docker CLI
COPY kubectl aws-iam-authenticator docker-credential-ecr-login helm helmfile docker docker-18.09.5 pup slack /bin/

# Download, compile and install git-crypt
RUN wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.6.0.tar.gz \
    && \
    tar xvzf git-crypt-0.6.0.tar.gz \
    && \
    cd git-crypt-0.6.0 \
    && \
    make \
    && \
    make install \
    && \
    rm -rf /git-crypt-0.6.0 /git-crypt-0.6.0.tar.gz

# Configure Docker CLI to use the ECR Credential helper and enable experimental mode
RUN mkdir -p ~/.docker && \
  echo '{"experimental": "enabled","credsStore": "ecr-login"}' > ~/.docker/config.json

# Initialise the Helm config directory and install the `helm-diff` plugin for Helm
RUN helm init --client-only && helm plugin install https://github.com/databus23/helm-diff --version v2.11.0+3
