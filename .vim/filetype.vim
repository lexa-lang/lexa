" filetype detection for Effekt
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.effekt setfiletype effekt
augroup end
