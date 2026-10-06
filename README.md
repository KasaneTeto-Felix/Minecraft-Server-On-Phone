# Minecraft Bedrock Server on Termux

A simple setup script for running a Minecraft Java server with Bedrock support on Android using Termux.

Uses:

- Paper
- Geyser
- Floodgate
- OpenJDK 25

The script works on both fresh Termux installations and existing setups.

## Requirements

- Android device
- Termux
- Internet connection for the initial setup
- Enough storage for the server

## Installation

Clone the repository:

```bash
git clone https://github.com/KasaneTeto-Felix/Minecraft-Server-On-Phone.git
cd Minecraft-Server-On-Phone
```

Make the script executable:

chmod +x setup.sh

Run it:

./setup.sh

The script will automatically:

Install required packages

Install OpenJDK 25 if needed

Detect the Java 25 binary

Download Paper

Download Geyser

Download Floodgate

Configure the server

Create a server launcher

Avoid downloading files that already exist


Start the Server

After setup:

bash ~/mc-server/start-server.sh

The launcher explicitly uses Java 25, so the system java command can still point to another Java version.

Ports

Edition	Port	Protocol

Java	25565	TCP
Bedrock	19132	UDP


For Bedrock players on the same network, connect using the Android device's local IP and port 19132.

Example:

Address: 192.168.x.x
Port: 19132

Server Settings

The default performance settings are:

view-distance=5
simulation-distance=4

The server launcher uses:

-Xms768M
-Xmx950M

Adjust these values depending on the device.

Java 25

The script does not modify the default Java version in Termux.

Even if:

java --version

returns Java 21, the server launcher will locate and use Java 25 directly.

License

MIT
