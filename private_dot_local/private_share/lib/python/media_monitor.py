import argparse
import sys
import signal
import gi

from typing import Callable
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

class MediaMonitor:
    
    def __init__(self, on_metadata: Callable[[Playerctl.Player], None]) -> None:
        self.on_metadata = on_metadata
        self.manager = Playerctl.PlayerManager()

    def _parse_arguments(self) -> argparse.Namespace:
        parser = argparse.ArgumentParser()
        parser.add_argument('--player', '-p', nargs='+', help="Set which players were listening to")
        return parser.parse_args()

    def _on_player_appeared(self, manager, player, selected_player=None) -> None:
        if player is not None and (selected_player is None or player.name in selected_player):
            self._init_player(manager, player)
    
    def _on_player_vanished(self, manager, player) -> None:
        sys.stdout.write('\n')
        sys.stdout.flush()

    def _on_play(self, player, status) -> None:
        self.on_metadata(player)

    def _init_player(self, manager, name) -> None:
        player = Playerctl.Player.new_from_name(name)
        player.connect('playback-status', self._on_play)
        # Variant is a glib thing
        player.connect('metadata', lambda player, variant: self.on_metadata(player))
        manager.manage_player(player)
        self.on_metadata(player)
    
    def _signal_handler(self, sig, frame) -> None:
        sys.stdout.write('\n')
        sys.stdout.flush()
        # loop.quit()
        sys.exit(0)

    def run(self):
        arguments = self._parse_arguments()
        loop = GLib.MainLoop()

        self.manager.connect('name-appeared', lambda *args: self._on_player_appeared(*args, arguments.player))
        self.manager.connect('player-vanished', self._on_player_vanished)

        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)

        for player in self.manager.props.player_names:
            if (arguments.player is not None) and (not player.name in arguments.player):
                continue

            self._init_player(self.manager, player)     
             
        loop.run()