local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
    s("declare_id", fmt([[declare_id!("{}");]], { i(1, "PROGRAM_ID") })),
    s("program", fmt([[
        #[program]
        pub mod {} {{
            use super::*;

            pub fn {}(ctx: Context<{}>) -> Result<()> {{
                {}
                Ok(())
            }}
        }}
    ]], {
        i(1, "my_program"),
        i(2, "initialize"),
        i(3, "Initialize"),
        i(0, "// logic"),
    })),
    s("accounts", fmt([[
        #[derive(Accounts)]
        pub struct {}<'info> {{
            {}
        }}
    ]], {
        i(1, "Initialize"),
        i(0, "#[account(mut)]\npub signer: Signer<'info>,"),
    })),
    s("account", fmt([[
        #[account]
        pub struct {} {{
            {}
        }}
    ]], {
        i(1, "State"),
        i(0, "pub authority: Pubkey,"),
    })),
    s("accinit", fmt([[
        #[account(
            init,
            payer = {},
            space = 8 + {}
        )]
        pub {}: Account<'info, {}>
    ]], {
        i(1, "signer"),
        i(2, "State::INIT_SPACE"),
        i(3, "state"),
        i(4, "State"),
    })),
    s("accmut", fmt([[
        #[account(mut)]
        pub {}: Account<'info, {}>
    ]], {
        i(1, "state"),
        i(2, "State"),
    })),
    s("signer", fmt([[pub {}: Signer<'info>]], { i(1, "signer") })),
    s("system_program", t([[pub system_program: Program<'info, System>]])),
    s("require", fmt([[require!({}, {});]], {
        i(1, "condition"),
        i(0, "ErrorCode::InvalidState"),
    })),
    s("require_eq", fmt([[require_eq!({}, {}, {});]], {
        i(1, "left"),
        i(2, "right"),
        i(0, "ErrorCode::InvalidState"),
    })),
    s("require_keys_eq", fmt([[require_keys_eq!({}, {}, {});]], {
        i(1, "left"),
        i(2, "right"),
        i(0, "ErrorCode::InvalidAuthority"),
    })),
    s("err", fmt([[return err!({});]], { i(0, "ErrorCode::InvalidState") })),
    s("emit", fmt([[emit!({} {{ {} }});]], {
        i(1, "MyEvent"),
        i(0, "authority: ctx.accounts.signer.key()"),
    })),
    s("event", fmt([[
        #[event]
        pub struct {} {{
            {}
        }}
    ]], {
        i(1, "MyEvent"),
        i(0, "pub authority: Pubkey,"),
    })),
    s("error_code", fmt([[
        #[error_code]
        pub enum {} {{
            #[msg("{}")]
            {},
        }}
    ]], {
        i(1, "ErrorCode"),
        i(2, "invalid state"),
        i(0, "InvalidState"),
    })),
}
