#!/bin/bash
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
REPO_URL="https://github.com/ttys3/oh-my-kitty.git"
if [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR")" ]; then
    echo "Creating backup..."
    BACKUP_DIR="$HOME/.config/kitty_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$DEST_DIR" "$BACKUP_DIR"
    echo "Backup moved to: $BACKUP_DIR"
fi
mkdir -p "$DEST_DIR"
git clone "$REPO_URL" "$DEST_DIR"
rm -rf "$DEST_DIR/.git" "$DEST_DIR/.gitignore"
echo "Files updated successfully!"

sed -i 's/^shell_integration .*/shell_integration enabled no-cursor/g' "$DEST_DIR/kitty.conf"

sed -i 's/background_opacity 1.0/background_opacity 0.98/g' "$DEST_DIR/kitty.conf"
cat << 'EOF' >> "$DEST_DIR/kitty.conf"
cursor_shape block
cursor_blink_interval 0.5
cursor_stop_blinking_after 15.0
repaint_delay 8
input_delay 1
sync_to_monitor yes
EOF

sed -i \
  -e 's/^background .*/background #18222e/' \
  -e 's/^foreground .*/foreground #ffffff/' \
  -e 's/^color0 .*/color0 #18222e/' \
  -e 's/^color8 .*/color8 #373f90/' \
  -e 's/^color4 .*/color4 #373f90/' \
  -e 's/^color12 .*/color12 #373f90/' \
  -e 's/^color5 .*/color5 #c372ac/' \
  -e 's/^color13 .*/color13 #c372ac/' \
  "$DEST_DIR/current-theme.conf"

cat << 'EOF' >> "$DEST_DIR/current-theme.conf"
selection_background #c372ac
selection_foreground #373f90
cursor #c372ac
EOF