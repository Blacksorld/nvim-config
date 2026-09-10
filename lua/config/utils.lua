local M = {}

M.get_api_key = function(key, fallback)
  local result = ""
  -- macOS: security keychain
  if vim.fn.executable("security") == 1 and vim.fn.has("macunix") == 1 then
    local cmd = "security find-generic-password -s " .. key .. " -w"
    local handle = io.popen(cmd)
    if handle ~= nil then
      result = handle:read("*a")
      handle:close()
    end
  end
  -- Linux: pass (GPG)
  if (not result or result == "") and vim.fn.executable("pass") == 1 then
    result = vim.fn.system("pass show " .. key)
    if vim.v.shell_error ~= 0 then
      result = ""
    end
  end
  if result and result ~= "" then
    return result:gsub("[%s\n\r]+$", "")
  end
  return os.getenv(fallback)
end

return M
