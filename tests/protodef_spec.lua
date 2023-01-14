describe("protodef", function()

    it("can be required", function()
        require("protodef")
    end)

    it("test ripgrep parsing ripgrep output", function()
        local test_rg = "proto/potsavingsprovider.proto:590:9:message GETRateHistoryResponse{"
        local fn, ln, cn = require("protodef").rg_parse(test_rg)
        assert.equals('proto/potsavingsprovider.proto', fn)
        assert.equals('590', ln)
        assert.equals('9', cn)
    end)

    it("get the import alias from the cWORD when in go-file", function()
        local cWord = "*potproto.GETBalanceRequest)"
        assert.equals('potproto', require("protodef").import_alias(cWord))
    end)

    it("get the import alias from the cWORD when in a proto", function()
        local cWord = "PUTUpdateRequest"
        assert.equals(nil, require("protodef").import_alias(cWord))
    end)
    it("get the import line from the import alias", function()
    end)

    it("get the service path from the import line", function()
    end)
end)
