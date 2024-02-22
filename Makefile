# this is the default path where configs are copied to
CONFIGDIR=${HOME}/.config

# this is where we put binaries that we install manually
BINARYDIR=/usr/local/bin

# where we clone source code of tools we build from src
SRCDIR=${HOME}/code/tools

# version of tools
KUBERNETES_VERSION=v1.26.10
HELM_VERSION=v3.14.0
KUSTOMIZE_VERSION=v5.3.0
GO_VERSION=1.20.13
YQ_VERSION=v4.40.5
PROTOC_VERSION=25.2
BUF_VERSION=1.29.0


.PHONY: all
all: essentials nvim

.PHONY: essentials
essentials: bash-config git
	sudo apt install build-essential
	sudo apt install curl
	sudo apt install gpg

.PHONY: ops
ops: kubernetes minio

###############
# Bash
# ----
# custom scripts meant to be sourced in your .bashrc
# most of them are specific to a single tool and will be sourced,
# if the tool is installed with this makefile
###############
.PHONY: bash-config
bash-config: .config/bash
	touch ${HOME}/.bashrc
	@echo copying $@ from $^ to ${CONFIGDIR}
	cp -r $^ ${CONFIGDIR}


###############
# Git
###############

.PHONY: git
git: git-install git-config

.PHONY: git-install
git-install:
	@echo installing git
	sudo apt install git

.PHONY: git-config
git-config: .gitconfig
	@echo configuring git --global
	cp $^ ${HOME}/.gitconfig
	@read -p "> git user.name: " user; git config --global user.name $$user 
	@read -p "> git user.email: " email; git config --global user.email $$email 

.PHONY: lazygit-install
lazygit-install:
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$(shell curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit ${BINARYDIR}
	rm lazygit.tar.gz lazygit


###############
# Neovim
###############

.PHONY: nvim
nvim: nvim-install nvim-config

.PHONY: nvim-install:
nvim-install:
	@echo installing \'neovim\' to ${BINARYDIR}
	@echo installing \`packer\' to ...

.PHONY: nvim-config
nvim-config: .config/nvim
	#TODO: source packer.lua and run PackerSync
	@echo copying $@ from $^ to ${CONFIGDIR}
	cp -r $^ ${CONFIGDIR}


###############
# Kubernetes
###############

.PHONY: kubernetes
kubernetes: kubectl-install kubectx-install kubernetes-config helm-install

.PHONY: kubernetes-config
kubernetes-config: bash-config
	grep -qxF 'source ${CONFIGDIR}/bash/kubernetes.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/kubernetes.sh' >> ${HOME}/.bashrc

.PHONY: kubectl-install
kubectl-install:
	curl -LO https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl
	sudo chmod +x kubectl
	sudo mv kubectl ${BINARYDIR}
	mkdir -p ${HOME}/.kube

.PHONY: kubectx-install
kubectx-install:
	mkdir -p ${SRCDIR}
	git clone git@github.com:ahmetb/kubectx.git ${SRCDIR}/kubectx
	sudo cp ${SRCDIR}/kubectx ${BINARYDIR}/kubectx
	sudo cp ${SRCDIR}/kubens ${BINARYDIR}/kubens
	sudo chmod +x ${BINARYDIR}/kubectx
	sudo chmod +x ${BINARYDIR}/kubens

.PHONY: kustomize-install
kustomize-install:
	curl -L -o kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
	tar -xzf kustomize.tar.gz
	sudo mv kustomize ${BINARYDIR}
	rm kustomize.tar.gz

.PHONY: helm-install
helm-install:
	curl -L -o helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
	tar -zxvf helm.tar.gz
	sudo mv linux-amd64/helm ${BINARYDIR}/helm
	rm -r linux-amd64 helm.tar.gz


###############
# Golang
###############

.PHONY: go
go: go-install go-config go-tools-install

.PHONY: go-install
go-install:
	@echo "installing golang ${GO_VERSION}"
	curl -L -o go.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go.tar.gz
	rm go.tar.gz

.PHONY: go-config
go-config:
	grep -qxF 'source ${CONFIGDIR}/bash/go.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/go.sh' >> ${HOME}/.bashrc

# can only be installed after go config is set
.PHONY: go-tools-install
go-tools-install:
	go install github.com/go-delve/delve/cmd/dlv@latest

.PHONY proto
proto: protoc-install protoc-config buf-install

.PHONY: protoc-install
protoc-install:
	curl -L -o protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
	unzip protoc.zip -d protoc
	sudo mv protoc ${BINARYDIR}

.PHONY: protoc-config
protoc-config:
	grep -qxF 'source ${CONFIGDIR}/bash/protoc.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/protoc.sh' >> ${HOME}/.bashrc

.PHONY: buf-install
buf-install:
	curl -L https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64 -o buf
	chmod +x buf
	sudo mv buf ${BINARYDIR}

###############
# Docker
###############

.PHONY: docker-keys
docker-keys:
	sudo apt-get update
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo  "deb [arch=$(shell dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(shell . /etc/os-release && echo "$$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update

.PHONY: docker-install
docker-install: docker-keys
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	getent group docker || sudo groupadd docker
	sudo usermod -aG docker $$USER
	newgrp docker

###############
# Minio Client
###############

.PHONY: minio
minio: mc-install mc-config

.PHONY: mc-install
mc-install:
	curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
	chmod +x mc
	sudo mv mc ${BINARYDIR}/mc
	
.PHONY: mc-config
mc-config:
	grep -qxF 'source ${CONFIGDIR}/bash/minio.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/minio.sh' >> ${HOME}/.bashrc

###############
# yq
###############

.PHONY: yq-install
yq-install:
	curl -L -o yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64
	chmod +x yq
	sudo mv yq ${BINARYDIR}

.PHONY: insomnia-install
insomnia-install:
	curl -1sLf 'https://packages.konghq.com/public/insomnia/setup.deb.sh' | sudo -E distro=ubuntu codename=focal bash
	sudo apt-get update
	sudo apt-get install insomnia


###############
# act
# test/run github actions locally
###############

.PHONY: act-install
act-install:
	curl -L -o act.tar.gz https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz
	tar -xzf act.tar.gz
	sudo mv act ${BINARYDIR}
