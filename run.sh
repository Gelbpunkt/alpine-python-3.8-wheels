#!/usr/bin/env bash
rm wheels/*
podman build -t wheels:latest . --no-cache
podman run -d --rm --name wheels wheels:latest
podman cp wheels:/wheels/ .
ls wheels > index
python3.8 order.py > index-order
