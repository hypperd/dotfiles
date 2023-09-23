from gi.repository import Gtk, Gio, GLib
from gi.repository.Gtk import Orientation, Align, Image, LevelBar
from pyws.typing import VAnchor, HAnchor, window


@window(name="brigtness-bar",
        vanchor=VAnchor.CENTER, hanchor=HAnchor.RIGHT, x=6)
class BrigtnessBar(Gtk.Window):
    def __init__(self, monitor: Gio.FileMonitor, file: Gio.File):
        self.monitor = monitor
        super().__init__(height_request=300, width_request=36)
        box = Gtk.Box(orientation=Orientation.VERTICAL, expand=True,
                      name="brigtness")

        self.bar = LevelBar(expand=False, halign=Align.CENTER,
                            orientation=Orientation.VERTICAL,
                            inverted=True)

        self.icon = Image(icon_name="display-brightness-symbolic",
                          halign=Align.CENTER, valign=Align.END, name="icon",
                          pixel_size=22, margin_bottom=7)

        overlay = Gtk.Overlay(expand=True)
        overlay.add(self.bar)
        overlay.add_overlay(self.icon)

        box.add(overlay)
        self.add(box)

        # callbacks
        self.connect("destroy", self.on_destroy)
        self.handler = self.monitor.connect("changed", self.on_change_file)
        self.timeout = GLib.timeout_add(1500, lambda *args: self.destroy())

        # On Init
        self.read_file(file)

    def on_destroy(self, window):
        self.monitor.disconnect(self.handler)

    def on_timeout(self):
        self.destroy()
        return GLib.SOURCE_REMOVE

    def on_change_file(self, monitor, file: Gio.File, other_file, event: Gio.FileMonitorEvent):
        if event == Gio.FileMonitorEvent.CHANGES_DONE_HINT:
            GLib.source_remove(self.timeout)
            self.read_file(file)
            self.timeout = GLib.timeout_add(1500, lambda *args: self.destroy())

    def read_file(self, file: Gio.File):
        value = Gio.DataInputStream.new(file.read()).read_line_utf8()
        percent = int(value[0]) / 4438

        self.bar.set_value(percent)

        ctx = self.icon.get_style_context()

        if percent >= 0.07 and ctx.has_class("low"):
            ctx.remove_class("low")
        elif percent <= 0.07 and not ctx.has_class("low"):
            ctx.add_class("low")
