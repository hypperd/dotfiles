from gi.repository import Gio
from window import Calendar, BrigtnessBar
import pyws


def open_brigtness_bar(monitor, file, file2, event):
    if (not pyws.app.is_open("brigtness-bar") and
            event == Gio.FileMonitorEvent.CHANGES_DONE_HINT):
        pyws.app.OpenWindow("brigtness-bar")


file = Gio.File.new_for_path("/sys/class/backlight/intel_backlight/brightness")
monitor = file.monitor_file(Gio.FileMonitorFlags.NONE, None)

monitor.connect("changed", open_brigtness_bar)

windows = [
    Calendar,
    BrigtnessBar(monitor, file),
]
