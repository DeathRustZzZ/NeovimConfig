local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
    s("main", fmt([[
        package main

        func main() {{
            {}
        }}
    ]], {
        i(0, ""),
    })),
    s("fn", fmt([[
        func {}({}) {} {{
            {}
        }}
    ]], {
        i(1, "name"),
        i(2, ""),
        i(3, ""),
        i(0, ""),
    })),
    s("meth", fmt([[
        func ({} {}) {}({}) {} {{
            {}
        }}
    ]], {
        i(1, "r"),
        i(2, "Receiver"),
        i(3, "Name"),
        i(4, ""),
        i(5, ""),
        i(0, ""),
    })),
    s("iferr", fmt([[
        if err != nil {{
            return {}
        }}
    ]], {
        i(0, "err"),
    })),
    s("test", fmt([[
        func Test{}(t *testing.T) {{
            {}
        }}
    ]], {
        i(1, "Name"),
        i(0, ""),
    })),
    s("subtest", fmt([[
        t.Run("{}", func(t *testing.T) {{
            {}
        }})
    ]], {
        i(1, "case"),
        i(0, ""),
    })),
    s("bench", fmt([[
        func Benchmark{}(b *testing.B) {{
            for i := 0; i < b.N; i++ {{
                {}
            }}
        }}
    ]], {
        i(1, "Name"),
        i(0, ""),
    })),
    s("ctx", t([[ctx := context.Background()]])),
}
