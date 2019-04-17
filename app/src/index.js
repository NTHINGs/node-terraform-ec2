var http = require("http");
var port = process.env.WWW_PORT || 8081;

http.createServer(function (req, res) {
   res.writeHead(200, {'Content-Type': 'text/plain'});

   res.end('Hola Mundo!');
}).listen(port);

console.log(`La magia pasa en el puerto: ${port}`);