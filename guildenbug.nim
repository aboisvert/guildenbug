import guildenstern
import guildenstern/ctxfull
import uri
from os import fileExists
from strutils import removePrefix

proc error(body: string, ctx: HttpCtx) =
  echo "Error: " & body
  ctx.reply(Http500, body)

proc serveFile(path: string, ctx: HttpCtx) =
  echo "File: " & path
  if fileExists(path):
    let f = open(path)
    defer: f.close()
    let content = f.readAll()
    ctx.reply(Http200, content)
  else:
    let msg = "Not found: " & path
    ctx.reply(Http404, msg)

proc serveDir(path: string, removePrefix: string, replacePrefix: string, ctx: HttpCtx) =
  var path = path
  path.removePrefix(removePrefix)
  serveFile(replacePrefix & path, ctx)

proc handleHttpGet(uri: Uri, ctx: HttpCtx) =
  if uri.path == "/":
    serveFile("index.html", ctx)
  serveDir(uri.path, "/", "./", ctx)

proc handleHttpRequest*(ctx: HttpCtx, headers: StringTableRef) {.gcsafe, raises: [].} =
  {.gcsafe.}:
    try:
      echo "handleHttpRequest"
      let uri = ctx.getUri().parseUri()
      echo "uri: " & $uri
      if ctx.getMethod() == "GET": handleHttpGet(uri, ctx)
      else: error("Unexpected method: " & ctx.getMethod(), ctx)
    except:
      let msg = getCurrentExceptionMsg()
      error(msg, ctx)
    ctx.closeSocket()

var server = new GuildenServer
server.initFullCtx(handleHttpRequest, 8080)
server.serve(multithreaded = true)
