#!/bin/bash
set -e

INSTALL_DIR="/opt/qflipper"
DESKTOP_FILE="/usr/share/applications/qFlipper.desktop"
ICON_URL="https://flipperzero.one/favicon-256x256.png"
ICON_PATH="/usr/share/icons/hicolor/256x256/apps/qflipper.png"

echo "🐬 Setting up or updating qFlipper..."

# 1️⃣ Determine latest version from Flipper's official update API
echo "🔍 Checking latest version..."
LATEST_URL=$(curl -s https://update.flipperzero.one/qFlipper/latest/linux/x86_64 | grep -oP 'https.*?\.AppImage')
if [ -z "$LATEST_URL" ]; then
  echo "❌ Could not fetch latest qFlipper version. Check internet connection."
  exit 1
fi

LATEST_FILE=$(basename "$LATEST_URL")
APP_EXEC="$INSTALL_DIR/$LATEST_FILE"

echo "📦 Latest qFlipper build: $LATEST_FILE"

# 2️⃣ Create directory and download new AppImage
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ -f "$LATEST_FILE" ]; then
  echo "✅ Latest version already installed."
else
  echo "⬇️ Downloading $LATEST_FILE ..."
  sudo curl -L -o "$LATEST_FILE" "$LATEST_URL"
  sudo chmod +x "$LATEST_FILE"

  # Remove old AppImages if any
  sudo find "$INSTALL_DIR" -type f -name "qFlipper-x86_64-*.AppImage" ! -name "$LATEST_FILE" -delete
fi

# 3️⃣ Install udev rules
echo "⚙️ Installing udev rules..."
sudo "$APP_EXEC" rules install || echo "⚠️ udev rule installation may require sudo manually"

# 4️⃣ Reload udev
echo "🔄 Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# 5️⃣ Add icon
echo "🖼️ Adding qFlipper icon..."
sudo wget -q -O "$ICON_PATH" "$ICON_URL" || echo "⚠️ Could not fetch icon."

# 6️⃣ Create desktop shortcut
echo "🧩 Creating/updating desktop entry..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Name=qFlipper
Comment=Flipper Zero Device Manager
Exec=$APP_EXEC
Icon=qflipper
Terminal=false
Type=Application
Categories=Utility;Development;
StartupNotify=true
EOF

# 7️⃣ Update desktop database
echo "🧹 Refreshing application database..."
sudo update-desktop-database

echo "✅ qFlipper installation/update complete!"
echo "🎯 Launch it from your Applications menu or run: qFlipper"
