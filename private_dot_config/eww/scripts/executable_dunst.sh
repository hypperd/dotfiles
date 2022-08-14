#!/usr/bin/env bash

dunstctl set-paused toggle
eww update dunst_paused="$(dunstctl is-paused)"