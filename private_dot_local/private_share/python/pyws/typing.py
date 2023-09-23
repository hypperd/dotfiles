import gi
from enum import Enum
from gi.types import GObjectMeta
from dataclasses import dataclass

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

gi.require_version('GtkLayerShell', '0.1')
from gi.repository.GtkLayerShell import Edge, Layer


class VAnchor(Enum):
    TOP = Edge.TOP
    BOTTOM = Edge.BOTTOM
    CENTER = None


class HAnchor(Enum):
    RIGHT = Edge.RIGHT
    LEFT = Edge.LEFT
    CENTER = None


@dataclass
class Window:
    name: str
    vanchor: VAnchor
    hanchor: HAnchor
    gtk_window: Gtk.Window
    layer: Layer = Layer.TOP
    focusable: bool = False
    x: int = None
    y: int = None

    def __call__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs
        return self

    def build_class(self):
        if (hasattr(self, 'args') and hasattr(self, 'kwargs')):
            return self.gtk_window(*self.args, **self.kwargs)
        return self.gtk_window()


def window(name: str, vanchor: VAnchor, hanchor: HAnchor,
           focusable: bool = False, layer: Layer = Layer.TOP, x: int = None,
           y: int = None):
    def decorated(window: GObjectMeta):
        return Window(name, vanchor, hanchor, window, layer, focusable, x, y)

    return decorated
