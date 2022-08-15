#!/usr/bin/env python3

import i3ipc
import signal
import sys
import json

def output_write(ipc):
    scratchpad = ipc.get_tree().scratchpad()
    window_list = scratchpad.floating_nodes
    num = len(window_list)

    if num == 0:
        sys.stdout.write("\n")
        sys.stdout.flush()
        return

    output = {
        'text': f"{num}",
        'tooltip': f"Scratchpad: {num} windows"
    }
    
    sys.stdout.write(f"{json.dumps(output)}\n")
    sys.stdout.flush()
        
def signal_handler(ipc):
    sys.stdout.write('\n')
    sys.stdout.flush()
    ipc.main_quit()
    sys.exit(0)

def main():
    ipc = i3ipc.Connection()
    output_write(ipc)

    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda sig, frame: signal_handler(ipc))

    ipc.on('window::move', lambda ipc, event: output_write(ipc))
    ipc.main()

if __name__ == "__main__":
    main()