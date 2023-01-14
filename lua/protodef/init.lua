local M = {}

-- protodef will take you to proto definition for the message if you are in a proto file
-- or the handler usage of the message if you are in a proto file
M.protodef = function()
    -- we need to know what proto message we are looking for
    --local current_word = vim.call('expand', '<cword>')
    local current_word = vim.call('expand', '<cWORD>')
    print(current_word)
    -- and what kind of file we are in
    local current_file = vim.fn.expand('%')

    local filename, line_number
    -- if we are in a proto file, find the handlerfunc
    if string.match(current_file, ".*proto$") ~= nil then
        local result = vim.fn.systemlist("rg 'func.*ctx.*" .. current_word .. "' -g '*.go' -n --column")
        local rg_last_line = result[#result]
        if rg_last_line == nil then print("not an existing proto message type") return end
        filename, line_number = rg_parse(rg_last_line)
        -- if we are in a go file, find the proto func
    elseif string.match(current_file, ".*go$") ~= nil then
        local result = vim.fn.systemlist("rg 'message " .. current_word .. "' -g '*.proto' -n --column")
        local rg_last_line = result[#result]
        if rg_last_line == nil then print("not an existing proto message type") return end
        filename, line_number = rg_parse(rg_last_line)

    else
        print("operation not supported for current filetype")
        return
    end

    -- open the file at the given line number
    vim.cmd(":e +" .. line_number .. " " .. filename)

    -- check the line under the cursor
    local line = vim.call('getline', '.')

    -- get the column and go straight to it
    -- we need to do this because ripgrep won't give us the columns we need
    local column = string.find(line, current_word)
    vim.cmd(":call cursor(" .. line_number .. "," .. column .. ")")
end

M.import_alias = function(cWord)
    local clean_cWord = string.gsub(cWord, "[*\\)]", "")
    local import_alias = string.match(clean_cWord, "(.*)%.")
    return import_alias

end

-- rg_parse gets the filename and line_number from the result
-- of a ripgrep command where the -n flag has been used
M.rg_parse = function(rip_grep_line)
    local filename = string.match(rip_grep_line, "(.+):%d+:%d+")
    local line_number = string.match(rip_grep_line, ":(%d+):")
    local column_number = string.match(rip_grep_line, ":%d+:(%d+):")
    return filename, line_number, column_number
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
