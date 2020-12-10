import guildenstern
import guildenstern/ctxfull
import uri
from os import fileExists
from strutils import removePrefix

# WARNING - Contains code unsafe for production use.
#           Will serve any local files!

proc error(body: string, ctx: HttpCtx) =
  ## Send back an error - HTTP/500
  echo "Error: " & body
  ctx.reply(Http500, body)

proc serveFile(path: string, ctx: HttpCtx) =
  ## Serve a file back to the client
  if fileExists(path):
    let f = open(path)
    defer: f.close()
    let content = f.readAll()
    ctx.reply(Http200, content)
  else:
    let msg = "Not found: " & path
    ctx.reply(Http404, msg)

proc serveDir(path: string, removePrefix: string, replacePrefix: string, ctx: HttpCtx) =
  ## Serve files from a local directory tree
  var path = path
  path.removePrefix(removePrefix)
  serveFile(replacePrefix & path, ctx)

proc handleHttpGet(uri: Uri, ctx: HttpCtx) =
  if uri.path == "/":
    # serve index.html by default
    serveFile("index.html", ctx)
  else:
    # otherwise, serve any local files from current directory
    serveDir(uri.path, "/", "./", ctx)

proc handleHttpRequest*(ctx: HttpCtx, headers: StringTableRef) {.gcsafe, raises: [].} =
  try:
    let uri = ctx.getUri().parseUri()
    if ctx.getMethod() == "GET": handleHttpGet(uri, ctx)
    else: error("Unexpected method: " & ctx.getMethod(), ctx)
  except:
    let msg = getCurrentExceptionMsg()
    error(msg, ctx)

echo "Starting server on port 8080..."
var server = new GuildenServer
server.initFullCtx(handleHttpRequest, 8080)
server.serve(multithreaded = true)
