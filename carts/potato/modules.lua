function module()
  local modules = {}
  local id = function(x) return x end

  function import(...)
    local exports = map({...}, id)

    return {
      from = function(moduleName)
        assert(modules[moduleName], "module " .. moduleName .. " not found")
        if (#exports == 1 and exports[1] == "*") then
          return modules[moduleName]
        end

        if (#exports == 0) then
          local export = modules[moduleName].default
          assert(export, "default export for " .. moduleName .. " not found")
          return modules[moduleName].default
        end

        return unpack(map(exports, function(v)
          return modules[moduleName][v]
        end))
      end,
    }
  end

  local function export(moduleName, exportName, value)
    if (modules[moduleName] == nil) then
      modules[moduleName] = {}
    end
    modules[moduleName][exportName] = value
  end

  function create_module(moduleName, module)
    local export = function(exportName, f) export(moduleName, exportName, f) end
    return module(export)
  end
end
module()
