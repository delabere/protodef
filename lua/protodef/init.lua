local M = {}

-- local buffer_text = vim.call('getline', 1, '$')
-- print("buffer text", P(buffer_text))
-- protodef will take you to proto definition for the message if you are in a proto file
-- or the handler usage of the message if you are in a proto file
M.protodef = function()
    -- we need to know what proto message we are looking for
    --local current_word = vim.call('expand', '<cword>')
    local current_word = vim.call('expand', '<cWORD>')
    print(current_word)
    -- and what kind of file we are in
    local current_file = vim.fn.expand('%')


    local filename, line_number, col
    -- if we are in a proto file, find the handlerfunc
    if string.match(current_file, ".*proto$") ~= nil then
        --print("pwd", vim.fn.getcwd())
        print(current_file)
        local service = string.match(current_file, "(.-)/")
        print("service", service)
        local search_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. service)
        print("search path", search_path)
        local rg_search = "rg '" .. current_word .. "' '" .. search_path .. "' -g '*.go' -n --column"

        print(rg_search)

        print("rg", rg_search)

        local result = vim.fn.systemlist(rg_search)
        -- local result = vim.fn.systemlist("rg 'func.*ctx.*" .. current_word .. "' -g '*.go' -n --column")
        local rg_last_line = result[#result]
        if rg_last_line == nil then print("not an existing proto message type") return end
        filename, line_number = M.rg_parse(rg_last_line)
        -- if we are in a go file, find the proto func


    elseif string.match(current_file, ".*go$") ~= nil then
        -- the text in the buffer, used later to grab the import line
        local buffer_text_1 = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local buffer_text = table.concat(buffer_text_1, "\n")
        local import_alias = M.import_alias(current_word)


        print("import alias", import_alias)
        local import_alias_regex = import_alias .. ' .-wearedev/(service.-)["\\]'
        print("import alias regex", import_alias_regex)
        local import_line = string.match(vim.inspect(buffer_text), import_alias_regex)
        print("import line", import_line)

        local message = M.message_name(current_word)

        local proto_path = vim.fn.resolve(vim.fn.getcwd() .. "/" .. import_line)
        --print("proto path", proto_path)

        local rg_search = "rg 'message " .. message .. "' '" .. proto_path .. "' -g '*.proto' -n --column"

        print("rg", rg_search)

        local result = vim.fn.systemlist(rg_search)
        local rg_last_line = result[#result]
        print("lastline", rg_last_line)

        if rg_last_line == nil then print("not an existing proto message type") return end
        filename, line_number, col = M.rg_parse(rg_last_line)

    else
        print("operation not supported for current filetype")
        return
    end

    -- open the file at the given line number
    vim.cmd(":e +" .. line_number .. " " .. filename)

    if col == nil then
        local line = vim.call('getline', '.')
        col = string.find(line, current_word)
    end
    -- move the cursor along to the beggining of the word
    vim.cmd(":call cursor(" .. line_number .. "," .. col .. ")")
end

M.import_alias = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*\\){}\\(\\),]", "")
    local import_alias = string.match(clean_cWord, "(.*)%.")
    return import_alias
end

M.message_name = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*\\){},]", "")
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
    --local column_number = string.match(rip_grep_line, ":%d+:(%d+):")
    return filename, line_number, 9
end

-- just a functin to test that the rg_parse function is working nicely
--M.test = function(line)
--    local filename, line_number, column_number = M.rg_parse(line)
--    print("filename:", filename)
--    print("line_number:", line_number)
--    print("column_number:", column_number)
--    return filename, line_number, column_number
--end

return M
