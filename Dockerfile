FROM node:alpine

# Install AWS CLI, jq and CA certificates
RUN apk -v --update add \
    python \
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
    && \
    pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic yq && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

# Install `cfn-create-or-update`, `@fountainhead/branch-officer`,
# `@fountainhead/helmfile-cleanup` and clear npm cache to reduce image size
RUN npm install -g cfn-create-or-update \
    @fountainhead/branch-officer@2.0.0 \
    @fountainhead/helmfile-cleanup@1.0.1 \
    && \
    npm cache clean --force

# Install kubectl, AWS IAM Authenticator, Helm client, Helmfile and Docker CLI
COPY kubectl aws-iam-authenticator helm helmfile docker /bin/

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
