const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server);
const port = Number(process.env.PORT || 3000);

app.get("/health", (_request, response) => {
  response.json({ status: "ok" });
});

app.get("/", (_request, response) => {
  response.type("html").send(`<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Node.js temps réel</title>
  <style>
    body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #f4f0e8; color: #18211d; font-family: Georgia, serif; }
    main { width: min(42rem, calc(100% - 3rem)); border-top: 4px solid #db3a34; padding: 2rem 0; }
    h1 { font-size: clamp(2rem, 8vw, 4.5rem); margin: 0 0 1rem; }
    p { font: 1.1rem/1.6 ui-monospace, monospace; }
    strong { color: #087e5b; }
  </style>
</head>
<body>
  <main>
    <h1>Temps réel.</h1>
    <p>Clients connectés : <strong id="count">0</strong></p>
    <p>Modifiez <code>nodejs-dev/app/server.js</code>, puis laissez <code>sync.sh --watch</code> recharger le serveur.</p>
  </main>
  <script src="/socket.io/socket.io.js"></script>
  <script>const socket = io(); socket.on("clients", count => document.querySelector("#count").textContent = count);</script>
</body>
</html>`);
});

io.on("connection", (socket) => {
  io.emit("clients", io.engine.clientsCount);
  socket.on("disconnect", () => io.emit("clients", io.engine.clientsCount));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Node.js écoute sur le port ${port}`);
});