let s:bufnr2lines = {}
let s:min_word_length = get(g:, 'asyncomplete_active_buffer_min_word_length', 1)

function! asyncomplete#sources#active_buffer#current_buffer_completor(opt, ctx) abort
    let l:typed = a:ctx['typed']
    let l:col = a:ctx['col']
    let l:kw = matchstr(l:typed, '\k\+$')
    let l:kwlen = len(l:kw)

    if l:kwlen == 0 | return | endif

    let l:startcol = l:col - l:kwlen
    let l:lines = filter(getline(1, '$'), { _, v -> match(v, l:kw) == -1 ? 0 : 1 })

    if len(l:lines) == 0 | return | endif

    let l:content = join(l:lines, ' ')
    let l:match_word_set = {}
    let l:match_start = 0
    while l:match_start >= 0
        let l:match = matchstrpos(l:content , printf('%s\k\+', l:kw), l:match_start)
        let l:match_word = l:match[0]
        let l:match_start = l:match[2]

        if len(l:match_word) > 1
            let l:match_word_set[l:match_word] = 1
        endif
    endwhile

    if empty(l:match_word_set) == 1 | return | endif
    if has_key(l:match_word_set, l:kw)
        call remove(l:match_word_set, l:kw)
    endif

    let l:matches = map(keys(l:match_word_set), { _, v -> {"word": v, "dup": 0, "icase": 0, "menu": "[ibuff]"} })

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#active_buffer#other_buffer_completor(opt, ctx) abort
    if empty(s:bufnr2lines) | return | endif

    let l:typed = a:ctx['typed']
    let l:col = a:ctx['col']
    let l:kw = matchstr(l:typed, '\k\+$')
    let l:kwlen = len(l:kw)

    if l:kwlen == 0 | return | endif

    let l:startcol = l:col - l:kwlen

    let l:cur_bufnr = bufnr('%')
    let l:bufnrs = filter(keys(s:bufnr2lines), { _, v -> v != l:cur_bufnr ? 1 : 0 })
    let l:lines = []
    for l:bufnr in l:bufnrs
        let l:buf_lines = s:bufnr2lines[l:bufnr]
        let l:filter_buf_lines = filter(l:buf_lines, { _, v -> match(v, l:kw) == -1 ? 0 : 1 })
        let l:lines += l:filter_buf_lines
    endfor

    let l:content = join(l:lines, ' ')
    let l:match_word_set = {}
    let l:match_start = 0
    while l:match_start >= 0
        let l:match = matchstrpos(l:content , printf('%s\k\+', l:kw), l:match_start)
        let l:match_word = l:match[0]
        let l:match_start = l:match[2]

        if len(l:match_word) > 1
            let l:match_word_set[l:match_word] = 1
        endif
    endwhile

    if empty(l:match_word_set) == 1 | return | endif
    if has_key(l:match_word_set, l:kw)
        call remove(l:match_word_set, l:kw)
    endif

    let l:matches = map(keys(l:match_word_set), { _, v -> {"word": v, "dup": 0, "icase": 0, "menu": "[obuff]"} })

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! s:get_event2func_ref() abort
    return {
    \ 'VimEnter': function('s:update_buf_lines'),
    \ 'BufWritePost': function('s:update_buf_lines'),
    \ 'BufWinEnter': function('s:update_buf_lines'),
    \ 'BufWinLeave': function('s:remove_buf_lines'),
    \ 'BufHidden': function('s:remove_buf_lines'),
    \ 'BufDelete': function('s:remove_buf_lines'),
    \ }
endfunction

function! asyncomplete#sources#active_buffer#get_current_buffer_source_options(opts) abort
    return a:opts
endfunction

function! asyncomplete#sources#active_buffer#get_other_buffer_source_options(opts) abort
    return extend({
        \ 'events': keys(s:get_event2func_ref()),
        \ 'on_event': function('s:on_event')
        \ }, a:opts)
endfunction

function! s:on_event(opt, ctx, event) abort
    let l:event2func_ref = s:get_event2func_ref()
    let l:Funcref = get(l:event2func_ref, a:event, 0)

    if type(l:Funcref) == 0 | return | endif

    call l:Funcref()
endfunction

function! s:remove_buf_lines() abort
    let l:bufnr = expand('<abuf>')
    if has_key(s:bufnr2lines, l:bufnr) | call remove(s:bufnr2lines, l:bufnr) | endif
endfunction

function! s:update_buf_lines() abort
    let l:bufnr = expand('<abuf>')
    let l:lines = getbufline(bufname(l:bufnr), 1, '$')
    let l:match_regex = printf('\w\{%d\}', s:min_word_length)
    let l:lines = filter(l:lines, { _, v -> match(v, l:match_regex) >= 0 ? 1 : 0 })
    let s:bufnr2lines[l:bufnr] = l:lines
endfunction

function! s:init_bufnr2lines() abort
    let l:opend_bufnrs = filter(range(1, bufnr('$')), { _, v -> bufexists(v) })

    for l:bufnr in l:opend_bufnrs
        let l:lines = getbufline(bufname(l:bufnr), 1, '$')
        let l:match_regex = printf('\w\{%d\}', s:min_word_length)
        let l:lines = filter(l:lines, { _, v -> match(v, l:match_regex) >= 0 ? 1 : 0 })
        let s:bufnr2lines[l:bufnr] = l:lines
    endfor
endfunction
