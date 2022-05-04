# PROTODEF
protodef is a simple plugin that enables you to goto-definition on proto message types from Go files and back

If you have your cursor on a proto message type in a handler function, it takes you to the message type definition in the `*.proto` file

If you have your cursor on a proto message type definition in a `*.proto` file, it takes you to the handler function which uses that message in a `*.go` file

It will only search for `proto` files in the `proto/` directory of your project, and `go` files in the `handler/` directory

# SETUP
Install it:
`Plug 'delabere/protodef'`
    
Use it:
`:Protodef`

Optionally you can map protodef to a keybind like so:
`nmap gp :Protodef<CR>`

# USAGE
Put your cursor on a proto message type and use `:protodef` or your mapping. Simple as that!
