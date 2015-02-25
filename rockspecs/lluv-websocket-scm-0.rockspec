package = "lluv-websocket"
version = "scm-0"

source = {
  url = "git://github.com/moteus/lua-lluv-websocket.git",
}

description = {
  summary = "Websockets for Lua based on libuv binding",
  homepage = "http://github.com/lipp/lua-websockets",
  license = "MIT/X11",
  detailed = "Provides async client and server for lluv."
}

dependencies = {
  "lua >= 5.1, < 5.4",
  "lua-websockets-core",
  "lluv",
}

build = {
  type = "builtin",

  modules = {
    ['lluv.websocket'            ] = 'src/lluv/websocket.lua',
    ['websocket.server_lluv'     ] = 'src/websocket/server_lluv.lua',
    ['websocket.client_lluv'     ] = 'src/websocket/client_lluv.lua',
    ['websocket.client_lluv_sync'] = 'src/websocket/client_lluv_sync.lua',
  }
}