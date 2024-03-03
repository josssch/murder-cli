#!/usr/bin/env bash

INSTALL_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
cp murder.sh "$INSTALL_DIR/murder"
chmod +x "$INSTALL_DIR/murder"

echo "Installed murder to $INSTALL_DIR/murder"
