describe("protodef", function()
    it("can be required", function()
        require("protodef")
    end)
    it("parses out the shit from a line", function()
        local test_rg = "proto/potsavingsprovider.proto:590:9:message GETRateHistoryResponse{"
        local fn, ln, cn = require("protodef").test(test_rg)
        assert.equals(fn, 'proto/potsavingsprovider.proto')
        assert.equals(ln, '590')
        assert.equals(cn, '9')

    end)
end)
