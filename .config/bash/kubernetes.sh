# use neovim for kubectl edit
export KUBE_EDITOR=nvim

# aliases
alias k=kubectl
alias kx=kubectx
alias kns=kubens

# completion
source <(kubectl completion bash)
source $HOME/code/tools/kubectx/completion/kubectx.bash
source $HOME/code/tools/kubectx/completion/kubens.bash

# completion for aliases
complete -o default -F __start_kubectl k
complete -F _kube_contexts kx
complete -F _kube_namespaces kns

source <(helm completion bash)
