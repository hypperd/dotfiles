#!/usr/bin/env python3

# Requirements:
#   - python-pydbus
#   - python-gobject
#   - tumbler

import os
import sys
import signal
import argparse

from gi.repository import Gio, GLib
from pydbus import SessionBus


def get_file_info(path: str) -> Gio.FileInfo:
    attributes = 'thumbnail::*,standard::content-type'
    file = Gio.File.new_for_path(path)
    return file.query_info(attributes, Gio.FileQueryInfoFlags.NONE)


def on_ready_thumb(handle: int, uris: list):
    for entry in uris:
        path = entry[7:]
        info = get_file_info(path)
        preview = info.get_attribute_byte_string("thumbnail::path")
        sys.stdout.write(f"{path}\0icon\x1f{preview}\n")
        sys.stdout.flush()


def on_exit():
    sys.exit(0)


def dbus_handler(files: dict) -> None:
    loop = GLib.MainLoop()
    bus = SessionBus()
    thumbnailer = bus.get("org.freedesktop.thumbnails.Thumbnailer1")
    thumbnailer.Queue(files['uri'], files['mime_type'], "large", 'default', 0)
    thumbnailer.Ready.connect(on_ready_thumb)
    thumbnailer.Finished.connect(lambda handle: on_exit())
    loop.run()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('path', help="folder path to search thumbnails")
    args = parser.parse_args()

    no_thumb = {
        'uri': list(),
        'mime_type': list()
    }

    entries = os.scandir(args.path)

    for entry in entries:
        info = get_file_info(entry.path)
        preview = info.get_attribute_byte_string("thumbnail::path")
        if preview:
            sys.stdout.write(f"{entry.path}\0icon\x1f{preview}\n")
            sys.stdout.flush()
        else:
            no_thumb['uri'].append(f'file://{entry.path}')
            no_thumb['mime_type'].append(info.get_content_type())

    for sig in [signal.SIGPIPE, signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda sig, frame: on_exit())

    if len(no_thumb['uri']) > 0:
        dbus_handler(no_thumb)


if __name__ == "__main__":
    main()
