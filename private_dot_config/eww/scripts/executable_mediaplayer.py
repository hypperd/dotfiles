#!/usr/bin/env python3

import argparse
import logging
import sys
import signal
import gi
import json
import os
import urllib.request
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

logger = logging.getLogger(__name__)

def time_convert(microseconds):
    seconds = round(microseconds / 1000000)
    return '{:02}:{:02}'.format(seconds // 60, seconds % 60)

def write_output(output=None):
    logger.info('Writing output')

    if output is None:
        output = {
            'title': '',
            'artist': '',
            'duration': '',
            'art': '',
            'status': ''
        }

    sys.stdout.write(f"{json.dumps(output)}\n")
    sys.stdout.flush()


def on_play(player, status, manager):
    logger.info('Received new playback status')
    on_metadata(player, player.props.metadata, manager)

def on_metadata(player, metadata, manager):
    logger.info('Received new metadata')
    
    if player.props.player_name == 'spotify' and 'mpris:trackid' in metadata.keys() and \
            ':ad:' in player.props.metadata['mpris:trackid']:
        write_output()
        return

    output = None
    duration = None
    status = player.props.status.lower()

    if 'mpris:length' in metadata.keys():
        duration = time_convert(player.props.metadata['mpris:length'])
        if status == 'playing':
            update_eww('true') 
        else: 
            update_eww('false')
    else:
        duration=''
        update_eww('false')

    art_url = player.props.metadata['mpris:artUrl']
    image = 'assets/music_fallback.png'
    
    if not art_url.startswith('file://'):
        if not art_url == '':
            id = player.props.metadata['mpris:trackid'].split('/')[-1]
            image = f"{os.getenv('HOME')}/.cache/eww/{id}.jpg"

            if not os.path.exists(image):
                try: 
                    urllib.request.urlretrieve(art_url, image) 
                except:
                    image='assets/music_fallback.png'
    else:
        image = art_url.replace('file://','')
    
    output = {
        'title': player.get_title(),
        'artist': player.get_artist(),
        'duration': str(duration),
        'art': image,
        'status': status
    }

    write_output(output)

def on_player_appeared(manager, player, selected_player=None):
    if player is not None and (selected_player is None or player.name == selected_player):
        init_player(manager, player)
    else:
        logger.debug("New player appeared, but it's not the selected player, skipping")

def on_player_vanished(manager, player):
    logger.info('Player has vanished')
    update_eww('false')
    write_output()


def init_player(manager, name):
    logger.debug('Initialize player: {player}'.format(player=name.name))
    player = Playerctl.Player.new_from_name(name)
    player.connect('playback-status', on_play, manager)
    player.connect('metadata', on_metadata, manager)
    manager.manage_player(player)
    on_metadata(player, player.props.metadata, manager)


def signal_handler(sig, frame):
    logger.debug('Received signal to stop, exiting')
    sys.stdout.write('\n')
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)

def update_eww(value):
    os.system(f'eww update poll_position={value}')

def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument('-v', '--verbose', action='count', default=0)

    # Define for which player we're listening
    parser.add_argument('--player')

    return parser.parse_args()


def main():
    arguments = parse_arguments()

    # Initialize logging
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG,
                        format='%(name)s %(levelname)s %(message)s')

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    # Log the sent command line arguments
    logger.debug('Arguments received {}'.format(vars(arguments)))

    manager = Playerctl.PlayerManager()
    loop = GLib.MainLoop()

    manager.connect('name-appeared', lambda *args: on_player_appeared(*args, arguments.player))
    manager.connect('player-vanished', on_player_vanished)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    for player in manager.props.player_names:
        if arguments.player is not None and arguments.player != player.name:
            logger.debug('{player} is not the filtered player, skipping it'
                         .format(player=player.name)
                         )
            continue

        init_player(manager, player)

    if len(manager.props.player_names) == 0:
        update_eww('false')
        write_output()

    loop.run()


if __name__ == '__main__':
    main()
