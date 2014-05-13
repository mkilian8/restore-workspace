#!/bin/bash

. tmux.session
TMUX_DATA_DIR="$(pwd)"/tmux.data


#restore browser
dwb -r $SESSION &

#restore sublime
subl $SESSION.sublime-project &

#restore tmux
if ! { tmux ls | grep $SESSION; } > /dev/null; then
    tmux new-session -d -c $WORKING_DIR -s $SESSION
    #find windows
    all_scripts="$(ls -1 $TMUX_DATA_DIR | sort -u)"
    win_names="$(echo $all_scripts | cut -d '_' -f 1 | uniq)"
    for w in $win_names; do
        echo initalizing window: $w
        scripts=($(echo $all_scripts | grep $w))
        #setup pane 0
        echo initalizing pane 0
        tmux send ". $TMUX_DATA_DIR/${scripts[0]}" C-m
        for ((i=1; i<${#scripts[*]}; i++)); do
            echo initalizing pane $i
            tmux splitw -c $WORKING_DIR
            tmux send ". $TMUX_DATA_DIR/${scripts[$i]}" C-m
        done
    done
    tmux select-layout $LAYOUT
else
    echo Tmux session already running
fi
tmux attach -t $SESSION
