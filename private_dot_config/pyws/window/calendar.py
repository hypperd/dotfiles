from gi.repository import Gtk
from pyws.typing import VAnchor, HAnchor, window


@window(name="calendar",
        vanchor=VAnchor.BOTTOM, hanchor=HAnchor.RIGHT, x=6, y=6)
class Calendar(Gtk.Window):
    def __init__(self):
        super().__init__(width_request=300)
        self.box = Gtk.Box(name="calendar", expand=True)

        self.calendar = Gtk.Calendar(expand=True)
        self.calendar.connect("month-changed", self._on_month)

        self.year, self.month, self.day = self.calendar.get_date()
        self._mark_day_toggle()

        self.box.add(self.calendar)
        self.add(self.box)

    def _mark_day_toggle(self):
        year, month, day = self.calendar.get_date()

        if year == self.year and month == self.month:
            self.calendar.mark_day(self.day)
        else:
            self.calendar.unmark_day(self.day)

    def _on_month(self, calendar):
        self._mark_day_toggle()
