#!/data/data/com.termux/files/usr/bin/bash

set -e

# ==========================================
# Minecraft Bedrock Server - Termux Setup
# Paper + Geyser + Floodgate
# ==========================================

SERVER_DIR="$HOME/mc-server"
PLUGINS_DIR="$SERVER_DIR/plugins"

PAPER_VERSION="26.2"
PAPER_BUILD="129"

PAPER_URL="https://fill-data.papermc.io/v1/objects/b1d8f6bfa1b6101fa8e947b53041cb3bdf5540e7b83b6547ca19ba7edefeb083/paper-26.2-129.jar"

GEYSER_URL="https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
FLOODGATE_URL="https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"

echo
echo "=========================================="
echo " Minecraft Bedrock Server"
echo " Paper + Geyser + Floodgate"
echo "=========================================="
echo

# ------------------------------------------
# Check Termux
# ------------------------------------------

if [ -z "$PREFIX" ]; then
    echo "[ERROR] Jalankan script ini di Termux."
    exit 1
fi

# ------------------------------------------
# Install required packages
# ------------------------------------------

echo "[1/8] Checking required packages..."

pkg update -y

pkg install -y curl openjdk-25

echo "[OK] Required packages ready."
echo

# ------------------------------------------
# Find Java 25
# ------------------------------------------

echo "[2/8] Detecting Java 25..."

JAVA25=""

# Known Termux OpenJDK 25 location
if [ -x "$PREFIX/lib/jvm/java-25-openjdk/bin/java" ]; then
    JAVA25="$PREFIX/lib/jvm/java-25-openjdk/bin/java"
fi

# Fallback: search all installed JVMs
if [ -z "$JAVA25" ]; then

    while IFS= read -r JAVA; do

        if "$JAVA" --version 2>/dev/null | grep -qE 'version "25([."]|-)'; then
            JAVA25="$JAVA"
            break
        fi

    done < <(find "$PREFIX/lib/jvm" -type f -path "*/bin/java" 2>/dev/null)

fi

if [ -z "$JAVA25" ]; then
    echo
    echo "[ERROR] Java 25 tidak ditemukan."
    echo "Coba jalankan:"
    echo "pkg reinstall openjdk-25"
    exit 1
fi

echo "[OK] Java 25:"
echo "$JAVA25"
echo

"$JAVA25" --version

# ------------------------------------------
# Create directories
# ------------------------------------------

echo
echo "[3/8] Creating server directories..."

mkdir -p "$SERVER_DIR"
mkdir -p "$PLUGINS_DIR"

# ------------------------------------------
# Paper
# ------------------------------------------

echo
echo "[4/8] Checking Paper..."

if [ -f "$SERVER_DIR/paper.jar" ]; then

    echo "[OK] paper.jar already exists."
    echo "Skipping download."

else

    echo "Downloading Paper $PAPER_VERSION build $PAPER_BUILD..."

    curl -L --fail \
        --progress-bar \
        -o "$SERVER_DIR/paper.jar" \
        "$PAPER_URL"

    echo "[OK] Paper downloaded."

fi

# ------------------------------------------
# Geyser
# ------------------------------------------

echo
echo "[5/8] Checking Geyser..."

if [ -f "$PLUGINS_DIR/Geyser-Spigot.jar" ]; then

    echo "[OK] Geyser already exists."
    echo "Skipping download."

else

    echo "Downloading Geyser..."

    curl -L --fail \
        --progress-bar \
        -o "$PLUGINS_DIR/Geyser-Spigot.jar" \
        "$GEYSER_URL"

    echo "[OK] Geyser downloaded."

fi

# ------------------------------------------
# Floodgate
# ------------------------------------------

echo
echo "[6/8] Checking Floodgate..."

if [ -f "$PLUGINS_DIR/floodgate-spigot.jar" ]; then

    echo "[OK] Floodgate already exists."
    echo "Skipping download."

else

    echo "Downloading Floodgate..."

    curl -L --fail \
        --progress-bar \
        -o "$PLUGINS_DIR/floodgate-spigot.jar" \
        "$FLOODGATE_URL"

    echo "[OK] Floodgate downloaded."

fi

# ------------------------------------------
# EULA
# ------------------------------------------

echo
echo "[7/8] Configuring server..."

if [ ! -f "$SERVER_DIR/eula.txt" ]; then
    echo "eula=true" > "$SERVER_DIR/eula.txt"
else
    sed -i 's/^eula=.*/eula=true/' "$SERVER_DIR/eula.txt"
fi

# ------------------------------------------
# server.properties
# ------------------------------------------

if [ ! -f "$SERVER_DIR/server.properties" ]; then

    cat > "$SERVER_DIR/server.properties" <<EOF
server-port=25565
view-distance=5
simulation-distance=4
max-players=10
motd=Android Bedrock Server
online-mode=true
EOF

else

    # Only change performance settings.
    # Existing server settings are preserved.

    if grep -q '^view-distance=' "$SERVER_DIR/server.properties"; then
        sed -i 's/^view-distance=.*/view-distance=5/' "$SERVER_DIR/server.properties"
    else
        echo "view-distance=5" >> "$SERVER_DIR/server.properties"
    fi

    if grep -q '^simulation-distance=' "$SERVER_DIR/server.properties"; then
        sed -i 's/^simulation-distance=.*/simulation-distance=4/' "$SERVER_DIR/server.properties"
    else
        echo "simulation-distance=4" >> "$SERVER_DIR/server.properties"
    fi

fi

# ------------------------------------------
# Create launcher
# ------------------------------------------

echo
echo "[8/8] Creating server launcher..."

cat > "$SERVER_DIR/start-server.sh" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SERVER_DIR="\$HOME/mc-server"

# Always use Java 25.
JAVA25="$JAVA25"

cd "\$SERVER_DIR"

echo
echo "=========================================="
echo " Starting Minecraft Server"
echo "=========================================="
echo

echo "Java:"
"\$JAVA25" --version

echo
echo "Server RAM: 950 MB"
echo "Java Port: 25565"
echo "Bedrock Port: 19132 UDP"
echo

exec "\$JAVA25" \
    -Xms768M \
    -Xmx950M \
    -jar paper.jar \
    --nogui
EOF

chmod +x "$SERVER_DIR/start-server.sh"

# ------------------------------------------
# Done
# ------------------------------------------

echo
echo "=========================================="
echo " SETUP COMPLETE!"
echo "=========================================="
echo
echo "Server directory:"
echo "$SERVER_DIR"
echo
echo "Start server:"
echo
echo "bash ~/mc-server/start-server.sh"
echo
echo "Java 25 will be used automatically."
echo
echo "Java Edition:"
echo "  Port: 25565"
echo
echo "Bedrock Edition:"
echo "  Port: 19132 UDP"
echo
echo "=========================================="
