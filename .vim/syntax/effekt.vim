" Vim syntax file
" Language:             Effekt (http://effekt-lang.org/)
" Maintainer:           Marius Müller
" URL:                  https://github.com/effekt-lang/effekt-neovim
" License:              Same as Vim
" Last Change:          08 February 2023
" ----------------------------------------------------------------------------

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

scriptencoding utf-8

syn case match
syn sync minlines=200 maxlines=1000

" Keywords
syn keyword effektKeyword do else if resume return
syn keyword effektKeyword box in match region unbox
syn keyword effektKeyword effect extends interface match record resource try while with skipwhite
syn keyword effektKeyword case nextgroup=effektCaseFollowing skipwhite
syn keyword effektKeyword val var nextgroup=effektNameDefinition skipwhite
syn keyword effektKeyword def fun nextgroup=effektNameDefinition skipwhite
hi def link effektKeyword Keyword


" Blocks
syn region effektBlock start=/{/ end=/}/ transparent fold


" Identifiers
syn match effektNameDefinition /\<[a-z][_A-Za-z0-9$]*\>/ contained
hi def link effektNameDefinition Identifier

syn match effektCapitalWord /\<[A-Z][A-Za-z0-9$]*\>/
hi def link effektCapitalWord Special


" Holes
syn match effektUnimplemented /<{\s*}>/
hi def link effektUnimplemented ERROR


" Types
syn region effektTypeStatement matchgroup=Keyword start=/\<type\_s\+\ze/ end=/$/ contains=effektTypeDeclaration

syn match effektTypeDeclaration /(/ contained nextgroup=effektTypeExtension contains=effektRoundBrackets skipwhite
syn match effektTypeDeclaration /=>\ze/ contained nextgroup=effektTypeDeclaration contains=effektTypeExtension skipwhite
syn match effektTypeDeclaration /\<[A-Z][_\.A-Za-z0-9$]*\>/ contained nextgroup=effektTypeExtension skipwhite
syn match effektTypeExtension /)\?\_s*\zs=>/ contained contains=effektTypeOperator nextgroup=effektTypeDeclaration skipwhite
hi def link effektTypeDeclaration Type
hi def link effektTypeExtension Keyword

syn match effektTypeAnnotation /\%([_a-zA-Z0-9$\s]:\_s*\)\ze[_=(\.A-Za-z0-9$]\+/ skipwhite nextgroup=effektTypeDeclaration contains=effektRoundBrackets
syn match effektTypeAnnotation /)\_s*:\_s*\ze[_=(\.A-Za-z0-9$]\+/ skipwhite nextgroup=effektTypeDeclaration
hi clear effektTypeAnnotation

syn region effektSquareBrackets matchgroup=effektSquareBracketsBrackets start="\[" end="\]" skipwhite nextgroup=effektTypeExtension contains=effektTypeDeclaration,effektSquareBrackets,effektTypeOperator
"syn match effektTypeOperator /[:<>]\+/ contained
hi def link effektSquareBracketsBrackets Type
"hi def link effektTypeOperator Keyword

syn region effektRoundBrackets start="(" end=")" skipwhite contained contains=effektTypeDeclaration,effektSquareBrackets,effektRoundBrackets


" Cases
syn match effektCaseFollowing /\<[_\.A-Za-z0-9$]\+\>/ contained contains=effektCapitalWord
hi def link effektCaseFollowing Special


" Constants
syn keyword effektSpecial true false
syn match effektSpecial "=>"
hi def link effektSpecial PreProc

syn match effektStringEmbeddedQuote /\\"/ contained
syn region effektString start=/"/ end=/"/ contains=effektStringEmbeddedQuote,effektEscapedChar,effektUnicodeChar
hi def link effektString String
hi def link effektStringEmbeddedQuote String

syn match effektNumber /\<0[dDfFlL]\?\>/ " Just a bare 0
syn match effektNumber /\<[1-9]\d*[dDfFlL]\?\>/  " A multi-digit number
syn match effektNumber /\<0[xX][0-9a-fA-F]\+[dDfFlL]\?\>/ " Hex number
syn match effektNumber /\%(\<\d\+\.\d*\|\.\d\+\)\%([eE][-+]\=\d\+\)\=[fFdD]\=/ " exponential notation 1
syn match effektNumber /\<\d\+[eE][-+]\=\d\+[fFdD]\=\>/ " exponential notation 2
syn match effektNumber /\<\d\+\%([eE][-+]\=\d\+\)\=[fFdD]\>/ " exponential notation 3
hi def link effektNumber Number

syn match effektChar /'.'/
syn match effektChar /'\\[\\"'ntbrf]'/ contains=effektEscapedChar
syn match effektChar /'\\u[A-Fa-f0-9]\{4}'/ contains=effektUnicodeChar
syn match effektEscapedChar /\\[\\"'ntbrf]/
syn match effektUnicodeChar /\\u[A-Fa-f0-9]\{4}/
hi def link effektChar Character
hi def link effektEscapedChar Special
hi def link effektUnicodeChar Special


" External
syn keyword effektExternal import module extern include
hi def link effektExternal Include


" Comments
syn region effektMultilineComment start="/\*" end="\*/" contains=effektMultilineComment,effektTodo,@Spell keepend fold
syn match effektSinglelineComment "//.*$" contains=effektTodo,@Spell
syn match effektTodo "\vTODO|FIXME|XXX" contained
hi def link effektMultilineComment Comment
hi def link effektTodo Todo
hi def link effektSinglelineComment Comment

let b:current_syntax = 'effekt'

" vim:set sw=2 sts=2 ts=8 et:
