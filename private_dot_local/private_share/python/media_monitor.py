import gi
from typing import Callable

gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib
from gi.repository.Playerctl import Player, PlayerName, PlaybackStatus


class PlayerManager:
    def __init__(self, selected_player=None):
        self.waiting_player = 0
        self.manager = Playerctl.PlayerManager()
        self.selected_player = selected_player
        self.loop = GLib.MainLoop()
        self.manager.connect(
            "name-appeared", lambda manager, player:
            self.on_player_appeared(player))
        self.manager.connect(
            "player-vanished", lambda manager, player:
            self.on_player_vanished(player))

    def run(self, on_empty: Callable[[None], None],
            on_metadata: Callable[[Player, GLib.Variant], None]) -> None:
        self.on_metadata = on_metadata
        self.on_empty = on_empty
        self.init_players()
        self.loop.run()

    def init_players(self) -> None:
        for player in self.manager.props.player_names:
            if (self.selected_player is not None
                    and self.selected_player != player.name):
                continue
            self.init_player(player)

    def on_player_appeared(self, player: PlayerName) -> None:
        if ((self.selected_player is None or player.name == self.selected_player)
                and player is not None):
            self.init_player(player)

    def on_player_vanished(self, player: Player) -> None:
        self.on_empty()

    def init_player(self, player_name: PlayerName) -> None:
        player = Player.new_from_name(player_name)
        if self.waiting_player != 0:
            GLib.source_remove(self.waiting_player)
            self.waiting_player = 0

        # Apparently spotify send incomplete info on initialization
        # and don't send a new event after. This try to fix it, waiting until
        # valid data is available
        if self.check_metadata(player):
            self.setup_player(player)
        else:
            self.waiting_player = GLib.timeout_add(
                500, self.wait_player, player_name)

    def wait_player(self, player: PlayerName) -> None:
        player = Playerctl.Player.new_from_name(player)
        if self.check_metadata(player):
            self.waiting_player = 0
            self.setup_player(player)
            return GLib.SOURCE_REMOVE
        return GLib.SOURCE_CONTINUE

    def check_metadata(self, player: Player) -> bool:
        title = player.get_title()
        artist = player.get_artist()
        valid_title = title != "" and title is not None
        valid_artist = artist != "" and artist is not None
        return valid_title and valid_artist

    def setup_player(self, player: Player):
        player.connect("playback-status", self.on_playback_status)
        player.connect("metadata", self.on_metadata)
        self.manager.manage_player(player)
        self.on_metadata(player, player.props.metadata)

    def on_playback_status(self, player: Player, status: PlaybackStatus) -> None:
        self.on_metadata(player, player.props.metadata)
