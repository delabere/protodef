local M = {}

-- protodef will take you to proto definition for the message if you are in a go file
-- or the handler usage of the message if you are in a proto file
M.protodef = function()
    -- we need to know what proto message we are looking for
    -- get the WORD under the cursor
    local current_word = vim.call('expand', '<cWORD>')
    -- get the full absolute path of the current file
    local current_file = vim.fn.expand('%:p')

    local filename, line_number, col
    if string.match(current_file, ".*proto$") ~= nil then
        -- if we are in a proto file, find the handler function
        filename, line_number = M._parse_proto(current_file, current_word)
    elseif string.match(current_file, ".*go$") ~= nil then
        -- we we are in the go file, find the proto message definition
        filename, line_number, col = M._parse_go(current_word)
    else
        print("operation not supported for current filetype")
        return
    end

    -- open the file at the given line number
    vim.cmd(":e +" .. line_number .. " " .. filename)

    -- after navigating to the ripgrep match, find out which char is the start of the token
    local line = vim.call('getline', '.')
    local tcol = string.find(line, current_word)

    if tcol ~= nil then
        col = tcol
    end

    -- move the cursor along to the beggining of the word
    vim.cmd(":call cursor(" .. line_number .. "," .. col .. ")")
end

M._parse_go = function(word)
    -- the text in the buffer, used later to grab the import line
    local buffer_text_1 = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_text = table.concat(buffer_text_1, "\n")
    local import_alias = M._import_alias(word)
    local import_alias_regex = import_alias .. ' "(.-)"'
    local import_line = string.match(buffer_text, import_alias_regex)

    local merge_path = M._merge_paths(vim.fn.getcwd(), import_line)

    local message = M._message_name(word)

    local rg_search = "rg 'message " .. message .. "' '" .. merge_path .. "' -g '*.proto' -n --column"

    local result = vim.fn.systemlist(rg_search)
    local rg_last_line = result[#result]

    if rg_last_line == nil then print("not an existing proto message type") return end
    local filename, line_number = M._rg_parse(rg_last_line)
    return filename, line_number, 9
end

M._parse_proto = function(file, word)
    local service = string.match(file, "(.-)/")
    local search_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. service)
    local rg_search = "rg 'func.*ctx.*" .. word .. "' '" .. search_path .. "' -g '*.go' -n --column"

    local result = vim.fn.systemlist(rg_search)
    local rg_last_line = result[#result]

    if rg_last_line == nil then print("not an existing proto message type") return end
    local filename, line_number = M._rg_parse(rg_last_line)
    return filename, line_number
end

M._import_alias = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*&\\){}\\(\\),]", "")
    local import_alias = string.match(clean_cWord, "(.*)%.")
    return import_alias
end

M._message_name = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*&\\){},]", "")
    local import_alias = string.match(clean_cWord, "%.(.*)")
    return import_alias
end

M._message_clean = function(cWord)
    local word = string.match(cWord, "message (.*)")
    return word
end

-- rg_parse gets the filename and line_number from the result
-- of a ripgrep command where the -n flag has been used
M._rg_parse = function(rip_grep_line)
    local filename = string.match(rip_grep_line, "(.+):%d+:%d+")
    local line_number = string.match(rip_grep_line, ":(%d+):")
    return filename, line_number
end

M._merge_paths = function(path1, path2)
    local path1_parts = {}
    for part in string.gmatch(path1, "[^/]+") do
        path1_parts[#path1_parts + 1] = part
    end
    local path2_parts = {}
    for part in string.gmatch(path2, "[^/]+") do
        path2_parts[#path2_parts + 1] = part
    end
    local link_point
    for i = 1, #path1_parts do
        if path1_parts[i] == path2_parts[1] then
            link_point = i
        end
    end

    local result = {}
    for i = 1, link_point do
        result[i] = path1_parts[i]
    end

    for i = 1, #path2_parts do
        result[i + link_point - 1] = path2_parts[i]
    end

    return "/" .. table.concat(result, "/")
end

return M
