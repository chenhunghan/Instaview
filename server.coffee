#
# Simple nodejs server for running the sample.
#
# http://stackoverflow.com/questions/6084360/node-js-as-a-simple-web-server
#
http = require("http")
url = require("url")
path = require("path")
fs = require("fs")
port = process.argv[2] or 8888
http.createServer((request, response) ->
  uri = url.parse(request.url).pathname
  filename = path.join(process.cwd(), uri)
  path.exists filename, (exists) ->
    unless exists
      response.writeHead 404,
        "Content-Type": "text/plain"

      response.write "404 Not Found\n"
      response.end()
      return
    filename += "/index.html"  if fs.statSync(filename).isDirectory()
    fs.readFile filename, "binary", (err, file) ->
      if err
        response.writeHead 500,
          "Content-Type": "text/plain"

        response.write err + "\n"
        response.end()
        return
      contentType = "text/plain"
      ext = path.extname(filename)
      switch ext
        when ".html"
          contentType = "text/html"
        when ".css"
          contentType = "text/css"
        when ".js"
          contentType = "text/javascript"
      console.log "Incoming ext: " + ext + ", content: " + contentType
      response.writeHead 200,
        "Content-Type": contentType

      response.write file, "binary"
      response.end()
      return

    return

  return
).listen parseInt(port, 10)
console.log "Static file server running at\n  => http://localhost:" + port + "/\nCTRL + C to shutdown"
