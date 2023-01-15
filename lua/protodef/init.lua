local M = {}

-- protodef will take you to proto definition for the message if you are in a go file
-- or the handler usage of the message if you are in a proto file
M.protodef = function()
    -- we need to know what proto message we are looking for
    -- get the WORD under the cursor
    local current_word = vim.call('expand', '<cWORD>')
    -- and what kind of file we are in
    local current_file = vim.fn.expand('%')


    local filename, line_number, col
    if string.match(current_file, ".*proto$") ~= nil then
        -- if we are in a proto file, find the handler function
        filename, line_number = M.parse_proto(current_file, current_word)
    elseif string.match(current_file, ".*go$") ~= nil then
        -- we we are in the go file, find the proto message definition
        filename, line_number, col = M.parse_go(current_word)
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

M.parse_go = function(word)
    -- the text in the buffer, used later to grab the import line
    local buffer_text_1 = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_text = table.concat(buffer_text_1, "\n")
    local import_alias = M.import_alias(word)


    local import_alias_regex = import_alias .. ' .-wearedev/(service.-)["\\]'
    local import_line = string.match(vim.inspect(buffer_text), import_alias_regex)

    local message = M.message_name(word)

    local proto_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. import_line)
    --print("proto path", proto_path)

    local rg_search = "rg 'message " .. message .. "' '" .. proto_path .. "' -g '*.proto' -n --column"

    local result = vim.fn.systemlist(rg_search)
    local rg_last_line = result[#result]

    if rg_last_line == nil then print("not an existing proto message type") return end
    local filename, line_number = M.rg_parse(rg_last_line)
    return filename, line_number, 9
end

M.parse_proto = function(file, word)
    local service = string.match(file, "(.-)/")
    local search_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. service)
    local rg_search = "rg 'func.*ctx.*" .. word .. "' '" .. search_path .. "' -g '*.go' -n --column"

    local result = vim.fn.systemlist(rg_search)
    local rg_last_line = result[#result]
    if rg_last_line == nil then print("not an existing proto message type") return end
    local filename, line_number = M.rg_parse(rg_last_line)
    return filename, line_number
end

M.import_alias = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*&\\){}\\(\\),]", "")
    local import_alias = string.match(clean_cWord, "(.*)%.")
    return import_alias
end

M.message_name = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*&\\){},]", "")
    local import_alias = string.match(clean_cWord, "%.(.*)")
    return import_alias
end

M.message_clean = function(cWord)
    print("cword", cWord)
    local word = string.match(cWord, "message (.*)")
    return word
end

-- rg_parse gets the filename and line_number from the result
-- of a ripgrep command where the -n flag has been used
M.rg_parse = function(rip_grep_line)
    local filename = string.match(rip_grep_line, "(.+):%d+:%d+")
    local line_number = string.match(rip_grep_line, ":(%d+):")
    return filename, line_number
end

return M
