"""
/home/ovos/.local/bin/spotifyd --device-type "speaker" --initial-volume 100 --on-song-change-hook "/home/ovos/.venvs/ovos/bin/python /home/ovos/spotifyd_hooks.py" --no-daemon
"""
import os
import time

from ovos_bus_client.message import Message
from ovos_bus_client.util import get_mycroft_bus

bus = get_mycroft_bus()

spotify_event = os.environ.get("PLAYER_EVENT")

# start
# {"TRACK_ID": "2MMRakTQnbyuqV7bALPPGw",
# "PLAYER_EVENT": "start", "PLAY_REQUEST_ID": "0",
# "POSITION_MS": "218271"}
if spotify_event == "start":
    bus.emit(Message("spotifyd.start", {
        "position": os.environ.get("POSITION_MS", 0),
        "track_id": os.environ.get("TRACK_ID")}))

# play
# environment variables {
# "DURATION_MS": "163066",
# "PLAYER_EVENT": "play",
# "PLAY_REQUEST_ID": "0",
# "TRACK_ID": "3KAS4vmuvRGP2BUQcxmu5i",
# "POSITION_MS": "25726"}
if spotify_event == "play":
    bus.emit(Message("spotifyd.play", {
        "position": os.environ.get("POSITION_MS", 0),
        "duration": os.environ.get("DURATION_MS"),
        "track_id": os.environ.get("TRACK_ID")}))

# pause
# environment variables {"POSITION_MS": "97601",
# "PLAYER_EVENT": "pause",
# "TRACK_ID": "3KAS4vmuvRGP2BUQcxmu5i",
# "DURATION_MS": "163066",
# "PLAY_REQUEST_ID": "0"}
if spotify_event == "pause":
    bus.emit(Message("spotifyd.pause", {
        "position": os.environ.get("POSITION_MS", 0),
        "duration": os.environ.get("DURATION_MS"),
        "track_id": os.environ.get("TRACK_ID")}))

# next
# environment variables {"PLAYER_EVENT": "load",
# "PLAY_REQUEST_ID": "1",
# "POSITION_MS": "0",
# "TRACK_ID": "38htK7dMpeSDNtkoKsy1cm"}
if spotify_event == "load":
    bus.emit(Message("spotifyd.load", {
        "position": os.environ.get("POSITION_MS", 0),
        "track_id": os.environ.get("TRACK_ID")}))

# volume (0-65535)
# environment variables {
# "VOLUME": "40166",
# "PLAYER_EVENT": "volumeset"}
if spotify_event == "volume":
    bus.emit(Message("spotifyd.volume",
                     {"volume": os.environ.get("VOLUME")}))

# when track is about to end we get info about next song
# can show a "coming up next" popup
# with environment variables {
# "PLAYER_EVENT": "preloading",
# "TRACK_ID": "5Dx8DhETu8DryPg4ap0DDc"}
if spotify_event == "preloading":
    bus.emit(Message("spotifyd.preloading",
                     {"track_id": os.environ.get("TRACK_ID")}))

# end of track
# {"TRACK_ID": "38htK7dMpeSDNtkoKsy1cm",
# "PLAYER_EVENT": "endoftrack",
# "PLAY_REQUEST_ID": "1"}
if spotify_event == "endoftrack":
    bus.emit(Message("spotifyd.end_of_track",
                     {"track_id": os.environ.get("TRACK_ID")}))

# new track start
# {"PLAYER_EVENT": "change",
# "OLD_TRACK_ID": "38htK7dMpeSDNtkoKsy1cm",
# "TRACK_ID": "5Dx8DhETu8DryPg4ap0DDc"}
if spotify_event == "change":
    bus.emit(Message("spotifyd.change", {
        "old_track_id": os.environ.get("OLD_TRACK_ID"),
        "track_id": os.environ.get("TRACK_ID")}))

# player disconnects from spotify app / playback changes to different device
# environment variables {
# "TRACK_ID": "6bckK7uOOyTzzSpGIaJIdT",
# "PLAY_REQUEST_ID": "17",
# "PLAYER_EVENT": "stop"}
if spotify_event == "stop":
    bus.emit(Message("spotifyd.stop",
                     {"track_id": os.environ.get("TRACK_ID")}))

time.sleep(1)

bus.close()
