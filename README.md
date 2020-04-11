# asyncomple-active-buffer.vim

This plugin provide two completor for [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)

## Installation
e.g. Plug
```
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'ta-daiki/asyncomple-active-buffer.vim'
```

## Setting
This plugin two completor

Completor | Source
------------ | -------------
`current_buffer_completor` | a current focused buffer (works like <C-x><C-n> completion)
`other_buffer_completor` | current opend buffers (excluded a current focused buffer)

```
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#active_buffer#get_current_buffer_source_options({
    \ 'name': 'cbuf',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#active_buffer#current_buffer_completor'),
    \ }))

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#active_buffer#get_other_buffer_source_options({
    \ 'name': 'obuf',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#active_buffer#other_buffer_completor'),
    \ }))
```

a option variable `asyncomplete_active_buffer_min_word_length` is provided  
if this set as described below  
```
let g:asyncomplete_active_buffer_min_word_length = 2
```
No candidates having less than 2 charactors appear in a complete list

