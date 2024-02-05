# this is the default path where configs are copied to
CONFIGDIR=${HOME}/.config

# this is where we put binaries that we install manually
BINARYDIR=/usr/local/bin

# where we clone source code of tools we build from src
SRCDIR=${HOME}/code/tools

# version of tools
KUBERNETESVERSION=v1.26.10
HELMVERSION=v3.14.0
KUSTOMIZE_VERSION=v5.3.0
GO_VERSION=1.20.13

all: essentials nvim

essentials: git
	sudo apt install build-essential
	sudo apt install curl
	sudo apt install gpg


###############
# Bash
# ----
# custom scripts meant to be sourced in your .bashrc
# most of them are specific to a single tool and will be sourced,
# if the tool is installed with this makefile
###############
bash-config: .config/bash
	touch ${HOME}/.bashrc
	@echo copying $@ from $^ to ${CONFIGDIR}
	cp -r $^ ${CONFIGDIR}


###############
# Git
###############

git: git-install git-config

git-install:
	@echo installing git
	sudo apt install git

git-config:
	@echo configuring git --global
	cp .gitconfig ${HOME}/.gitconfig
	@read -p "> git user.name: " user; git config --global user.name $$user 
	@read -p "> git user.email: " email; git config --global user.email $$email 


###############
# Neovim
###############

nvim: nvim-install nvim-config

nvim-install:
	@echo installing \'neovim\' to ${BINARYDIR}
	@echo installing \`packer\' to ...

nvim-config: .config/nvim
	#TODO: source packer.lua and run PackerSync
	@echo copying $@ from $^ to ${CONFIGDIR}
	cp -r $^ ${CONFIGDIR}


###############
# Kubernetes
###############

kubernetes: bash-config kubectl-install helm-install
	grep -qxF 'source ${CONFIGDIR}/bash/kubernetes.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/kubernetes.sh' >> ${HOME}/.bashrc

kubectl-install:
	curl -LO https://dl.k8s.io/release/${KUBERNETESVERSION}/bin/linux/amd64/kubectl
	sudo chmod +x kubectl
	sudo mv kubectl ${BINARYDIR}
	mkdir -p ${HOME}/.kube

kubectx-install:
	mkdir -p ${SRCDIR}
	git clone git@github.com:ahmetb/kubectx.git ${SRCDIR}/kubectx
	sudo cp ${SRCDIR}/kubectx ${BINARYDIR}/kubectx
	sudo cp ${SRCDIR}/kubens ${BINARYDIR}/kubens
	sudo chmod +x ${BINARYDIR}/kubectx
	sudo chmod +x ${BINARYDIR}/kubens

kustomize-install:
	curl -L -o kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.3.0/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
	tar -xzf kustomize.tar.gz
	sudo mv kustomize ${BINARYDIR}
	rm kustomize.tar.gz


helm-install:
	curl -L -o helm.tar.gz https://get.helm.sh/helm-${HELMVERSION}-linux-amd64.tar.gz
	tar -zxvf helm.tar.gz
	sudo mv linux-amd64/helm ${BINARYDIR}/helm
	rm -r linux-amd64 helm.tar.gz


###############
# Golang
###############

go-all: go-install go-config go-tools-install

go-install:
	@echo "installing golang ${GO_VERSION}"
	curl -L -o go.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf go.tar.gz
	rm go.tar.gz

go-config:
	grep -qxF 'source ${CONFIGDIR}/bash/go.sh' ${HOME}/.bashrc || echo 'source ${CONFIGDIR}/bash/go.sh' >> ${HOME}/.bashrc

# can only be installed after go config is set
go-tools-install:
	go install github.com/go-delve/delve/cmd/dlv@latest

###############
# Minio Client
###############
mc: mc-install mc-config
	

