#!/usr/bin/env bash
export PATH=$HOME/.local/bin:$PATH
./delete-git-hashes.sh
rm wheels/*
podman build -t wheels:latest . --no-cache
podman run -d --rm --name wheels wheels:latest
podman cp wheels:/wheels/ .
devpi upload wheels/*
