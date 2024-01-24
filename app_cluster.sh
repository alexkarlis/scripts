#!/bin/bash
# This script sets up a tmux session with multiple panes, each running the k9s command with different arguments
# for the different Neptune CRDs:
# 'applications', 
# 'appvaults', 
# 'snapshots', 
# 'resourcesummaryuploads', 
# 'resourcebackups', 
# 'snapshotrestores', 
# 'backuprestores', 
# 'backups'
#
# Required:
# - k9s
# - tmux
#
 # Usage:
#   ./app_cluster.sh <KUBECONFIG_PATH>
#   ./app_cluster.sh ~/.kube/my-caas23

kubeconfig=${1:-"$KUBECONFIG"}
echo $kubeconfig

window_name="${kubeconfig##*/}"
echo $window_name

function open_pane() {
  tmux send-keys "export KUBECONFIG=$kubeconfig" C-m
  # change the namespace to the namespace your AstraConnector is installed in
  tmux send-keys "k9s --command $1 --namespace neptune-system --headless" C-m
}

exists=$(tmux list-windows -F '#I "#W"' | awk "\$2 ~ \"$window_name\" { print \$1 }")
echo $exists

if [[ -n "$exists" ]]
then
  tmux kill-window -t $exists
fi

# tmux list-sessions 
tmux new-window
tmux send-keys "export KUBECONFIG=$kubeconfig" C-m
tmux send-keys 'k9s --command pods --namespace neptune-system' C-m
tmux rename-window "$window_name"

# First, split the window into two panes (left and right)
tmux split-window -h
tmux select-pane -L

tmux split-window -v
tmux send-keys "export KUBECONFIG=$kubeconfig" C-m

tmux select-pane -R

open_pane "applications"
tmux split-window -h

open_pane "appvaults"

tmux select-pane -L

tmux split-window -v

tmux split-window -v
open_pane "snapshots"

tmux select-pane -U
open_pane "resourcesummaryuploads"

tmux select-pane -U
tmux split-window -v
open_pane "resourcebackups"

tmux select-pane -R
tmux split-window -v

tmux split-window -v
open_pane "snapshotrestores"

tmux select-pane -U
open_pane "backuprestores"

tmux select-pane -U
tmux split-window -v
open_pane "backups"
