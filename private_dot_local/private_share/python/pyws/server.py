import pyws
import sys
import os
import importlib
from pyws.comman import REGISTER, SESSION_BUS, LAYER_SHELL_NAMESPACE_NAME, InvalidArgs
from dasbus.typing import Str
from pyws.typing import Window, VAnchor, HAnchor
from dasbus.server.interface import dbus_interface
from typing import List, Dict
import gi

gi.require_version('GtkLayerShell', '0.1')
gi.require_version('Gtk', '3.0')
from gi.repository import GtkLayerShell, Gtk, Gdk, Gio


def init_server():
    config_home = os.getenv("XDG_CONFIG_HOME", os.path.join(
        os.getenv("HOME"), ".config"))

    cache_home = os.getenv("XDG_CACHE_HOME", os.path.join(
        os.getenv("HOME"), ".cache"))

    config_dir = os.path.join(config_home, "pyws")

    sys.path.insert(0, config_dir)
    sys.pycache_prefix = os.path.join(cache_home, "pyws")
    config = importlib.import_module("init")

    Gtk.init()

    pyws.init(Server(config.windows))

    SESSION_BUS.publish_object(REGISTER.object_path, pyws.app)
    SESSION_BUS.register_service(REGISTER.service_name)

    screen = Gdk.Screen.get_default()
    css_provider = Gtk.CssProvider()

    css_file = Gio.File.new_for_path(os.path.join(config_dir, "style.css"))
    css_provider.load_from_file(css_file)

    # css_provider.load_from_path("./style.css")
    Gtk.StyleContext.add_provider_for_screen(
        screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    Gtk.main()


@dbus_interface(REGISTER.interface_name)
class Server:
    def __init__(self, windows: List[Window]):
        self._windows = {window.name: window for window in windows}
        self._opened: Dict[str, Gtk.Window] = dict()

    def OpenWindow(self, name: Str) -> None:
        if name not in self._windows:
            raise InvalidArgs(f"{name} is not declared")

        if name in self._opened:
            print(f"{name} is always open")
            return

        definition = self._windows.get(name)
        gtk_window = self._build_window(definition)

        self._opened[definition.name] = gtk_window

        gtk_window.show_all()

    def _build_window(self, definition: Window) -> Gtk.Window:
        window = definition.build_class()

        window.connect("destroy",
                       lambda *args: self._on_destroy(definition.name))

        GtkLayerShell.init_for_window(window)
        GtkLayerShell.set_layer(window, definition.layer)
        GtkLayerShell.set_namespace(window, LAYER_SHELL_NAMESPACE_NAME)
        GtkLayerShell.set_keyboard_interactivity(window, definition.focusable)

        hanchor = definition.hanchor
        vanchor = definition.vanchor

        if (vanchor != VAnchor.CENTER):
            GtkLayerShell.set_anchor(window, vanchor.value, True)
            if (definition.y):
                GtkLayerShell.set_margin(window, vanchor.value, definition.y)

        if (hanchor != HAnchor.CENTER):
            GtkLayerShell.set_anchor(window, hanchor.value, True)
            if (definition.x):
                GtkLayerShell.set_margin(window, hanchor.value, definition.x)

        return window

    def is_open(self, name: str):
        return name in self._opened

    def _on_destroy(self, name: str):
        self._opened.pop(name)

    def CloseWindow(self, name: Str) -> None:
        gtk_window = self._opened.get(name)
        gtk_window.destroy()

    def ToggleWindow(self, name: Str) -> None:
        if name not in self._opened:
            self.OpenWindow(name)
        else:
            self.CloseWindow(name)

    def Inspector(self):
        Gtk.Window.set_interactive_debugging(True)
