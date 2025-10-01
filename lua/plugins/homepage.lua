return {
  "nvimdev/dashboard-nvim",
  lazy = false,
  opts = function()
    local logo = [[
 ______    _______  _______  __   __  ___   ______  
|    _ |  |       ||       ||  | |  ||   | |      | 
|   | ||  |   _   ||  _____||  |_|  ||   | |  _    |
|   |_||_ |  | |  || |_____ |       ||   | | | |   |
|    __  ||  |_|  ||_____  ||_     _||   | | |_|   |
|   |  | ||       | _____| |  |   |  |   | |       |
|___|  |_||_______||_______|  |___|  |___| |______|
]]

    logo = string.rep("\n", 8) .. logo .. "\n\n"

    -- helper: read projects from project.nvim history
    local function get_projects(max)
      local projects = {}
      local ok, Path = pcall(require, "plenary.path")
      if not ok then
        return projects
      end

      local history_file = Path:new(vim.fn.stdpath("data")) / "project_nvim" / "project_history"
      if history_file:exists() then
        local lines = history_file:readlines()
        for i, line in ipairs(lines) do
          if max and i > max then
            break
          end
          -- show folder name, but cd into full path
          local project_path = vim.trim(line)
          if project_path ~= "" and vim.fn.isdirectory(project_path) == 1 then
            table.insert(projects, {
              action = function()
                vim.cmd.cd(project_path)
                vim.api.nvim_buf_delete(0, { force = true })
                Snacks.picker.explorer()
              end,
              desc = vim.fn.fnamemodify(line, ":t"),
              icon = " ",
            })
          end
        end
      end
      return projects
    end

    local opts = {
      theme = "doom",
      hide = {
        statusline = false,
      },
      config = {
        header = vim.split(logo, "\n"),
        center = {
          {
            action = "lua LazyVim.pick()()",
            desc = " Find File",
            icon = " ",
            key = "f",
          },
          {
            action = "ene | startinsert",
            desc = " New File",
            icon = " ",
            key = "n",
          },
          {
            action = 'lua LazyVim.pick("oldfiles")()',
            desc = " Recent Files",
            icon = " ",
            key = "r",
          },
          {
            action = "Telescope projects",
            desc = " Projects",
            icon = " ",
            key = "p",
          },
          {
            action = 'lua LazyVim.pick("live_grep")()',
            desc = " Find Text",
            icon = " ",
            key = "g",
          },
          {
            action = "lua LazyVim.pick.config_files()()",
            desc = " Config",
            icon = " ",
            key = "c",
          },
          -- {
          --   action = 'lua require("persistence").load()',
          --   desc = " Restore Session",
          --   icon = " ",
          --   key = "s",
          -- },
          {
            action = "LazyExtras",
            desc = " Extras",
            icon = " ",
            key = "x",
          },
          {
            action = "Lazy",
            desc = " Lazy",
            icon = "󰒲 ",
            key = "l",
          },
          {
            action = function()
              vim.api.nvim_input("<cmd>qa<cr>")
            end,
            desc = " Quit",
            icon = " ",
            key = "q",
          },
        },
        --   footer = function()
        --     local stats = require("lazy").stats()
        --     local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        --     return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        --   end,
      },
    }

    -- pad desc and key format for nice alignment
    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- add recent projects dynamically (limit to 5)
    local projects = get_projects(5)
    if #projects > 0 then
      for i, proj in ipairs(projects) do
        proj.desc = " " .. proj.desc .. string.rep(" ", 43 - #proj.desc)
        proj.key = tostring(i)
        proj.key_format = "  %s"
        table.insert(opts.config.center, proj)
      end
    end

    -- reopen dashboard after closing Lazy
    if vim.o.filetype == "lazy" then
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(vim.api.nvim_get_current_win()),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
          end)
        end,
      })
    end

    return opts
  end,
}
