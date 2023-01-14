describe("protodef", function()

    it("can be required", function()
        require("protodef")
    end)

    it("test ripgrep parsing ripgrep output", function()
        local test_rg = "proto/potsavingsprovider.proto:590:9:message GETRateHistoryResponse{"
        local fn, ln, cn = require("protodef").rg_parse(test_rg)
        assert.equals('proto/potsavingsprovider.proto', fn)
        assert.equals('590', ln)
        assert.equals(9, cn)
    end)

    it("test ripgrep parsing ripgrep output", function()
        local test_rg = "/Users/jackrickards/src/github.com/monzo/wearedev/service.pot/proto/pot.proto:301:1:message GETBalanceRequest {"
        local fn, ln, cn = require("protodef").rg_parse(test_rg)
        assert.equals('proto/pot.proto', fn)
        assert.equals('301', ln)
        assert.equals(9, cn)
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

    it("get the message name from the cWORD", function()
        local cWord = "*potproto.GETBalanceRequest)"
        assert.equals('GETBalanceRequest', require("protodef").message_name(cWord))
    end)
end)
