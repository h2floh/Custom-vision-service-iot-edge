FROM ubuntu:xenial

RUN echo "BUILD MODELCONTROL: EdgeDeployment"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-dev \
        libcurl4-openssl-dev \
        libboost-python-dev \
        libgtk2.0-dev \
        # Install Azure CLI prerequisits
        curl \
        apt-transport-https \
        lsb-release 
        #gpg

# Install Microsoft Signing Key
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

# Add Azure CLI Repo
RUN AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    azure-cli

# Add IoT Extension
RUN az extension add --name azure-cli-iot-ext

# Install Python packages
COPY /build/amd64-requirements.txt ./
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -r amd64-requirements.txt

# Cleanup
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

ADD /app/ .

# Expose the port
EXPOSE 80

ENTRYPOINT [ "python3", "-u", "./main.py" ]