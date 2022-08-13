#!/usr/bin/env python3

import i3ipc
import signal
import sys
import json


def output_write(ipc, event=None):
    scratchpad = ipc.get_tree().scratchpad()
    window_list = scratchpad.floating_nodes

    num = len(window_list)

    if num > 0:

        output = {
            'text': f"{num}"
        }
        
        sys.stdout.write(f"{json.dumps(output)}\n")
        sys.stdout.flush()
    else:
        sys.stdout.write("\n")
        sys.stdout.flush()


def main():

    ipc = i3ipc.Connection()
    output_write(ipc)

    for sig in [signal.SIGINT, signal.SIGTERM]:
        ipc.main_quit()


    ipc.on('window::move', lambda ipc, event: output_write(ipc, event))
    ipc.main()

if __name__ == "__main__":
    main()