# Bedrock + Java Proximity Voice (developer starter)

This project is a cross-platform **starter** for proximity voice chat using a browser companion client, a Node.js signaling/position service, a Paper/Spigot-style Java plugin source project, and a Bedrock Dedicated Server behavior-pack prototype.

## What is included
- `client/`: browser voice client, intended for Android Chrome and Windows browsers.
- `server/`: Node.js WebSocket signaling server plus an HTTP position bridge.
- `java-plugin/`: Java source for a Paper plugin that posts player coordinates to the bridge.
- `BedrockJavaProximityVoice.mcaddon`: Bedrock behavior pack prototype for a Bedrock Dedicated Server you administer.
- `BedrockJavaProximityVoice-Project.zip`: all source files and setup notes.

## Honest compatibility limits
- This is **not a finished, tested, production release**. The included web client/server are a prototype; test with two clients before use.
- Browser voice uses WebRTC peer-to-peer mesh. Larger rooms need an SFU such as LiveKit/mediasoup and a TURN relay for networks that block direct connections.
- The web app is a companion app, not an in-game microphone mod. Keep it open while playing and grant microphone permission.
- Java automatic proximity requires the Java plugin to be installed on the Java server (Paper is recommended). Public servers where you cannot install plugins won't provide coordinates to this system.
- Bedrock automatic proximity requires a **Bedrock Dedicated Server you control**, plus the experimental `@minecraft/server-net` module and its permission configured. The module is pre-release and unavailable on clients and Realms. It will not read coordinates from arbitrary public servers or DonutSMP unless their administrators add compatible integration.
- Java and Bedrock users can share a voice room only when both server integrations publish coordinates to the same voice-server room and the voice service is reachable.
- The included Bedrock add-on's API dependency and script networking support must be checked against the exact BDS version. Importing a `.mcaddon` does not itself enable network permissions.

## Requirements
- Node.js 20+ for the voice server.
- Java 21+ and Gradle 8+ to build the Paper plugin (version may need adjustment to match your server).
- A modern browser on Android/Windows.
- HTTPS for remote browser microphone use. `http://localhost` is generally allowed for local testing.
- For remote use, host the Node server behind HTTPS/WSS and configure firewall rules.

## Start voice server (local test)
1. Install Node.js 20 or newer.
2. Open a terminal in `server/`.
3. Run `npm install`
4. Run `npm start`
5. On the same PC open `http://localhost:8080`.
6. For a phone on the same Wi-Fi, use `http://PC-LAN-IP:8080` to load the page, but microphone access usually requires HTTPS on the phone. Use HTTPS for real tests.
7. Enter the same room name and each player's Minecraft username. Press Connect and allow microphone permission.

Without a Minecraft integration, the app can connect players, but proximity will not be accurate because coordinates are not being published.

## Java Paper plugin
1. Build using `java-plugin/` with Java 21 and Gradle: `gradle build`.
2. Copy `java-plugin/build/libs/BedrockJavaProximityVoice-0.1.0.jar` into the Java server's `plugins/` folder.
3. Start the server once, then edit `plugins/BedrockJavaProximityVoice/config.yml`.
4. Set `voice-server-url` to your bridge endpoint, `room` to the same room users enter in the app, and configure a bridge token.
5. Restart the server. Check console logs for bridge errors.
6. All players who should share voice must be on servers integrated into the same voice room.

The Java plugin posts coordinates every second. Protect the bridge with a long random token and HTTPS.

## Bedrock Dedicated Server behavior pack
1. Import `BedrockJavaProximityVoice.mcaddon` into Minecraft Bedrock.
2. Install/activate the behavior pack on a Bedrock Dedicated Server you administer.
3. Update `VOICE_SERVER_URL`, `ROOM_NAME`, and `BRIDGE_TOKEN` in `behavior_pack/scripts/main.js`.
4. Enable `@minecraft/server-net` for the pack in the BDS permissions configuration as required by your exact version.
5. Restart BDS and inspect logs. This API is experimental/pre-release and the script may require changes for your version.
6. Do not use on Realms or expect it to work on servers you don't control.

## Public servers
- If a public server offers no compatible plugin/add-on integration, the system cannot know Minecraft positions and cannot do true automatic proximity.
- A player-side overlay or manually joined voice room can still provide voice communication, but not reliable block-distance filtering.
- Do not try to bypass a server's rules, anti-cheat, or access controls.

## Security before internet deployment
- Serve the browser app over HTTPS/WSS.
- Set a strong `BRIDGE_TOKEN` environment variable for the Node server and use the same token in integrations.
- Add authentication/authorization per room and rate limits before opening it to the public.
- Configure a TURN server for reliable WebRTC connectivity; the demo uses a public STUN server only.
- Consider a WebRTC SFU for larger rooms.

## Optional cloud deployment (Render)

This repository includes a `Dockerfile` and `render.yaml` for deployment on Render.
1. Put the project folder in a GitHub repository you control.
2. In Render, choose **New > Blueprint**, connect that repository, and deploy the `render.yaml` blueprint.
3. Render will create a `BRIDGE_TOKEN` secret automatically. Keep it private and copy it only into the server integration config that needs it.
4. After deployment, open `https://YOUR-SERVICE.onrender.com/health`; expect JSON containing `"ok":true`.
5. Open the service URL in a browser to load the voice client. Use HTTPS/WSS; do not use plain HTTP from a phone over the internet.

Notes: A free instance may sleep when idle, so it is not a reliable always-on voice server. This prototype has no built-in TURN relay, user authentication, or production-grade access controls; internet voice connections may fail on some networks. Do not use it for a public community until those are added. Cloud deployment alone does not connect to a Minecraft public server; the game server must supply position data for proximity behavior.
