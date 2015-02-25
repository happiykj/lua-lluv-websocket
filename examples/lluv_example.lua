local uv  = require"lluv"
local ws  = require"lluv.websocket"

local server = ws.new()
server:bind("127.0.0.1", 12345, function(self, err)
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
    cli:handshake({'echo'}, function(self, err)
      if err then
        print("Server handshake error:", err)
        return cli:close()
      end

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
cli:connect("ws://127.0.0.1:12345", "echo", function(self, err)
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
