#!/usr/bin/python3

import sys
import signal
from typing import List
from gi.repository import Gio, GLib

ROFI = ["rofi", "-dmenu", "-theme", "wallpaper"]
ATTRIBUTES = "thumbnail::path-xlarge,standard::content-type"
WALLPAPER = ["wallpaper", "set"]
FALLBACK_ICON = "image"


class Wallpaper:
    def __init__(self):
        self.rofi = None

    def _rofi_row(self, path: str, thumb: str) -> bytes:
        row = f"{path}\0icon\x1f{thumb}\n"
        return row.encode()

    def on_exit(self):
        self.rofi.send_signal(15)
        exit(0)

    def init(self) -> None:
        path = "/home/hypper/Pictures/Wallpapers"

        for sig in [signal.SIGPIPE, signal.SIGINT, signal.SIGTERM]:
            signal.signal(sig, lambda sig, frame: self.on_exit())

        self.rofi = Gio.Subprocess.new(
            ROFI,
            Gio.SubprocessFlags.STDIN_PIPE | Gio.SubprocessFlags.STDOUT_PIPE)
        stdin = self.rofi.get_stdin_pipe()

        wall_dir = Gio.File.new_for_path(path)
        enumrator = wall_dir.enumerate_children(
            ATTRIBUTES, Gio.FileQueryInfoFlags.NONE)

        uris = list()
        types = list()

        while info := enumrator.next_file():
            thumb = info.get_attribute_as_string("thumbnail::path-xlarge")
            file = enumrator.get_child(info)

            if thumb is None:
                uris.append(file.get_uri())
                types.append(info.get_content_type())
                continue

            stdin.write(self._rofi_row(file.get_path(), thumb))

        enumrator.close()

        loop = GLib.MainLoop()

        if len(types) > 0 and len(uris) > 0:
            thumbnailer, id = self._async_thumbs(uris, types)
            self.rofi.wait_async(None, lambda *args: thumbnailer.Dequeue(id))
        else:
            stdin.close()

        self.rofi.wait_async(None, self._await_rofi, loop)

        loop.run()

    def _set_wallpaper(self, file: str):
        Gio.Subprocess.new(["wallpaper", "set", file],
                           Gio.SubprocessFlags.NONE)

    def _on_ready_thumb(self, handle: int, uris: list):
        stdin = self.rofi.get_stdin_pipe()
        for uri in uris:
            file = Gio.File.new_for_uri(uri)
            info = file.query_info(ATTRIBUTES, Gio.FileQueryInfoFlags.NONE)
            thumb = info.get_attribute_as_string("thumbnail::path-xlarge")
            stdin.write(self._rofi_row(file.get_path(), thumb))

    def _async_thumbs(self, uris: List[str], types: List[str]):
        from dasbus.connection import SessionMessageBus
        bus = SessionMessageBus()
        thumbnailer = bus.get_proxy(
            "org.freedesktop.thumbnails.Thumbnailer1",
            "/org/freedesktop/thumbnails/Thumbnailer1",
        )
        thumbnailer.Error.connect(self.on_error)
        thumbnailer.Finished.connect(
            lambda *args: self.rofi.get_stdin_pipe().close())
        thumbnailer.Ready.connect(self._on_ready_thumb)
        id = thumbnailer.Queue(uris, types, "x-large", 'default', 0)
        return thumbnailer, id

    def on_error(self, handle: int, failed_uris: list, error_code: int,
                 message: str):
        stdin = self.rofi.get_stdin_pipe()
        for uri in failed_uris:
            stdin.write(self._rofi_row(uri[7:], FALLBACK_ICON))

        sys.stderr.write(f'{message}\n')
        sys.stderr.flush()

    def _await_rofi(self, source, res, loop):
        stdout = self.rofi.get_stdout_pipe()
        data = Gio.DataInputStream.new(stdout)
        file = data.read_line_utf8()
        if file[0] is not None:
            self._set_wallpaper(file[0])
        loop.quit()


if __name__ == "__main__":
    w = Wallpaper()
    w.init()
