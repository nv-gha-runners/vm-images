local downwardapi_file_path  = "/etc/downwardapi/labels"
local node_name_label_key = "kubevirt.io/nodeName"
local g_node_name = nil

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function split(str, sep)
  local t = {}
  for s in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(t, s)
  end
  return t
end

local function get_node_name()
  if g_node_name ~= nil then
    return g_node_name, nil
  end

  local downwardapi_file, err = io.open(downwardapi_file_path, "r")
  if downwardapi_file == nil then
    return nil, string.format("failed to open downwardapi file: %s", err)
  end

  for line in downwardapi_file:lines() do
    if starts_with(line, node_name_label_key) then
      local node_name_label = split(line, "=")
      g_node_name = node_name_label[2]
      g_node_name = g_node_name:sub(2, -2)
      break
    end
  end

  downwardapi_file:close()

  if g_node_name == nil then
    return nil, string.format("node name label not found in downwardapi file")
  end

  return g_node_name, nil
end


function add_node_name(tag, timestamp, record)
  local node_name, err = get_node_name()
  if node_name == nil then
    io.stderr:write(string.format("failed to get node name: %s\n", err))
    return 0, 0, 0
  end

  new_record = record
  new_record["node_name"] = node_name

  return 2, 0, new_record
end
