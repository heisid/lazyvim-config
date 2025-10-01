return {
  "nvim-zh/colorful-winsep.nvim",
  config = function()
    require("colorful-winsep").setup({
      highlight = function()
        return vim.fn.synIDattr(vim.fn.hlID("Statement"), "fg")
      end,
    })
  end,
}
