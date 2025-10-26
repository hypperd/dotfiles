#!/usr/bin/python

import sys
import dbus
import signal

from gi.repository import GLib
from ddcutil import Dddcutil, VcpChagedEvent, BRIGHTNESS_VCP
from dbus.mainloop.glib import DBusGMainLoop


def on_vcp_value_changed(event: VcpChagedEvent, display_number: int) -> None:
    if event.vcp_code != BRIGHTNESS_VCP:
        return

    if event.display_number != display_number:
        return

    _ = sys.stdout.write(f"{event.vcp_new_value}\n")
    _ = sys.stdout.flush()


def signal_handler(sig, frame):
    sys.exit(0)


def exit_err(msg: str):
    _ = sys.stderr.write(f"error: {msg}")
    _ = sys.stderr.flush()
    exit(1)


def main():
    loop = GLib.MainLoop()
    session_bus = dbus.SessionBus(mainloop=DBusGMainLoop())

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    ddcutil = Dddcutil(session_bus)
    detected = ddcutil.list_detect()

    if detected.error_status > 0:
        exit_err(detected.error_message)

    if detected.number_of_displays == 0:
        exit_err("Any supported monitor found!")

    first_monitor_number = detected.detected_displays[0].display_number
    current_brightness = ddcutil.get_vcp(first_monitor_number, BRIGHTNESS_VCP)

    if current_brightness.error_status > 0:
        exit_err(current_brightness.error_message)

    _ = sys.stdout.write(f"{current_brightness.current_value}\n")
    _ = sys.stdout.flush()

    ddcutil.on_vcp_value_changed(
        lambda e: on_vcp_value_changed(e, first_monitor_number)
    )
    loop.run()


if __name__ == "__main__":
    main()
