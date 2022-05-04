if exists('g:loaded_protodef') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" command to run our plugin
command! Protodef lua require'protodef'.protodef()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_protodef = 1
