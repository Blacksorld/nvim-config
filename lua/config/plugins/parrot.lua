return {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    config = function()
        local utils = require("config.utils")
        require("parrot").setup {
            providers = {
                anthropic = {
                    name = "anthropic",
                    endpoint = "https://api.anthropic.com/v1/messages",
                    model_endpoint = "https://api.anthropic.com/v1/models",
                    api_key = utils.get_api_key("api/claude", "CLAUDE_API_KEY"),
                    params = {
                        chat = { max_tokens = 4096 },
                        command = { max_tokens = 4096 },
                    },
                    topic = {
                        model = "claude-haiku-4-5-20251001",
                        params = { max_tokens = 32 },
                    },
                    headers = function(self)
                        return {
                            ["Content-Type"] = "application/json",
                            ["x-api-key"] = self.api_key,
                            ["anthropic-version"] = "2023-06-01",
                        }
                    end,
                    models = {
                        "claude-sonnet-4-6",
                        "claude-haiku-4-5-20251001",
                    },
                    preprocess_payload = function(payload)
                        for _, message in ipairs(payload.messages) do
                            message.content = message.content:gsub("^%s*(.-)%s*$", "%1")
                        end
                        if payload.messages[1] and payload.messages[1].role == "system" then
                            -- remove the first message that serves as the system prompt as anthropic
                            -- expects the system prompt to be part of the API call body and not the messages
                            payload.system = payload.messages[1].content
                            table.remove(payload.messages, 1)
                        end
                        return payload
                    end,
                },
            },
            -- Option to move the cursor to the end of the file after finished respond
            chat_free_cursor = true,
        }
    end,
}
