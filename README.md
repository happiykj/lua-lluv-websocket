# lluv-websocket
[![Licence](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE)
[![Build Status](https://travis-ci.org/moteus/lua-lluv-websocket.svg?branch=master)](https://travis-ci.org/moteus/lua-lluv-websocket)
[![Coverage Status](https://coveralls.io/repos/moteus/lua-lluv-websocket/badge.svg?branch=master)](https://coveralls.io/r/moteus/lua-lluv-websocket?branch=master)

This library includes stream interface for lluv and lluv backend for [lua-websockets](https://github.com/lipp/lua-websockets)

## lluv status
 * PING/PONG - done
 * WSS supports - done
 * UTF8 validate - done (except some fast fail cases)
 * IPv6 - done
 * Check mask flag according RFC 6455 - done
 * Validate RSV bits - done
 * Extensions general (Section 9 of [RFC 6455](https://tools.ietf.org/html/rfc6455#section-9) and [RFC 7692](https://tools.ietf.org/html/rfc7692) ) - supported (need more tests)
 * Extensions PMCE(Section 7 of [RFC 7692](https://tools.ietf.org/html/rfc7692#section-7)) (permessage-deflate) - supported (need more tests)

## [lua-websockets](https://github.com/lipp/lua-websockets) backend status
 * Async server - done (not tested)
 * Async client - done (not tested)
 * Sync client  - done (not tested)

## Autobahn|Testsuite
 * [Server](http://moteus.github.io/websocket/autobahn/reports/servers/index.html)
 * [Client](http://moteus.github.io/websocket/autobahn/reports/clients/index.html)

## Usage
### Echo client/server
```Lua
local uv  = require"lluv"
local ws  = require"lluv.websocket"

local wsurl, sprot = "ws://127.0.0.1:12345", "echo"

local server = ws.new()
server:bind(wsurl, sprot, function(self, err)
  if err then
    print("Server error:", err)
    return server:close()
  end

  server:listen(function(self, err)
    if err then
      print("Server listen:", err)
      return server:close()
    end

    local cli = server:accept()
    cli:handshake(function(self, err, protocol)
      if err then
        print("Server handshake error:", err)
        return cli:close()
      end
      print("New server connection:", protocol)

      cli:start_read(function(self, err, message, opcode)
        if err then
          print("Server read error:", err)
          return cli:close()
        end

        cli:write(message, opcode)
      end)
    end)
  end)
end)

local cli = ws.new()
cli:connect(wsurl, sprot, function(self, err)
  if err then
    print("Client connect error:", err)
    return cli:close()
  end

  local counter = 1
  cli:start_read(function(self, err, message, opcode)
    if err then
      print("Client read error:", err)
      return cli:close()
    end
    print("Client recv:", message)

    if counter > 10 then
      return cli:close(function(self, ...)
        print("Client close:", ...)
        server:close(function(self, ...)
          print("Server close:", ...)
        end)
      end)
    end
    cli:write("Echo #" .. counter)
    counter = counter + 1
  end)

  cli:write("Echo #0")
end)

uv.run()
```
