function module()
  local modules = {}

  function import(...)
    local exports = {...}

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
          local export = modules[moduleName][v]
          assert(export, "export " .. v .. " not found")
          return export
        end))
      end,
    }
  end

  function create_module(moduleName, module)
    local function export(moduleName, exportName, value)
      if (modules[moduleName] == nil) then
        modules[moduleName] = {}
      end
      modules[moduleName][exportName] = value
    end

    local export = function(exportName, f) export(moduleName, exportName, f) end
    return module(export)
  end
end
module()
