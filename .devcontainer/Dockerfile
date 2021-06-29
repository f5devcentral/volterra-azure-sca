# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.183.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get -y install --no-install-recommends curl \
    && sudo apt-get install software-properties-common ca-certificates curl apt-transport-https lsb-release gnupg -y

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
RUN sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN sudo apt-get update
RUN sudo apt-get install terraform -y && terraform -install-autocomplete

#RUN sudo apt-get install golang -y

RUN git clone https://github.com/tfutils/tfenv.git $HOME/.tfenv 
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> $HOME/.bash_profile 
RUN mkdir -p $HOME/.local/bin/ 
RUN ln -s $HOME/.tfenv/bin/* $HOME/.local/bin
#RUN tfenv install 0.13.7 && \
#    tfenv use 0.13.7