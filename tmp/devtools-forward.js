const net = require("net");

const LOCAL_PORT = 9223;
const TARGET_HOST = "host.docker.internal";
const TARGET_PORT = 9333;

const server = net.createServer((client) => {
  const target = net.connect(TARGET_PORT, TARGET_HOST);

  client.pipe(target);
  target.pipe(client);

  const closeBoth = () => {
    client.destroy();
    target.destroy();
  };

  client.on("error", closeBoth);
  target.on("error", closeBoth);
  client.on("close", closeBoth);
  target.on("close", closeBoth);
});

server.on("error", (err) => {
  console.error("Forwarder error:", err.message);
  process.exit(1);
});

server.listen(LOCAL_PORT, "127.0.0.1", () => {
  console.log(`Forwarding 127.0.0.1:${LOCAL_PORT} -> ${TARGET_HOST}:${TARGET_PORT}`);
});
