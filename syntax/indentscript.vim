if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syntax case match

syntax keyword iscKeyword def class if else elif for while return import from nextgroup=iscIdentifier skipwhite
syntax keyword iscKeyword in as with pass break continue try except finally nextgroup=iscIdentifier skipwhite
syntax keyword iscKeyword raise assert del global nonlocal yield nextgroup=iscIdentifier skipwhite

syntax keyword iscKeywordJS function const let var extends implements interface nextgroup=iscIdentifier skipwhite
syntax keyword iscKeywordJS package private protected public export default nextgroup=iscIdentifier skipwhite
syntax keyword iscKeywordJS case switch do nextgroup=iscIdentifier skipwhite

syntax keyword iscAsync async await nextgroup=iscIdentifier skipwhite

syntax keyword iscBuiltin print len range enumerate lambda map filter reduce
syntax keyword iscBuiltin sorted reversed zip all any sum min max abs round
syntax keyword iscBuiltin str int float bool list dict set tuple
syntax keyword iscBuiltinJS console Array Object String Number Boolean
syntax keyword iscBuiltinJS Math Date JSON Promise Error RegExp

syntax keyword iscBoolean True False None null undefined
syntax keyword iscOperator and or not is typeof instanceof delete void new super static get set

syntax keyword iscSelf self this nextgroup=iscDot skipwhite

syntax keyword iscException Exception TypeError ValueError AttributeError
syntax keyword iscException KeyError IndexError RuntimeError SyntaxError

syntax match iscNumber "\v<\d+>"
syntax match iscNumber "\v<\d+\.\d+>"
syntax match iscNumber "\v<\d+e[+-]?\d+>"
syntax match iscNumber "\v<\d+\.\d+e[+-]?\d+>"
syntax match iscHex "\v<0[xX]\x+>"
syntax match iscOctal "\v<0[oO]\o+>"
syntax match iscBinary "\v<0[bB][01]+>"
syntax match iscNumber "\v<\d+_\d+>"

syntax region iscString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=iscStringEscape,iscStringInterpolation
syntax region iscString start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=iscStringEscape,iscStringInterpolation
syntax region iscTemplate start=+`+ skip=+\\`+ end=+`+ contains=iscTemplateInterpolation
syntax region iscFString start=+[fF]"+ skip=+\\\\\|\\"+ end=+"+ contains=iscFStringInterpolation,iscStringEscape
syntax region iscFString start=+[fF]'+ skip=+\\\\\|\\'+ end=+'+ contains=iscFStringInterpolation,iscStringEscape
syntax region iscMultilineString start=+"""+ end=+"""+ contains=iscStringEscape
syntax region iscMultilineString start=+'''+ end=+'''+ contains=iscStringEscape

syntax match iscStringEscape "\\[nrtbfv\"'\\]" contained
syntax match iscStringEscape "\\x\x\{2}" contained
syntax match iscStringEscape "\\u\x\{4}" contained
syntax match iscStringEscape "\\U\x\{8}" contained

syntax region iscStringInterpolation contained matchgroup=iscInterpolationDelim start=+\${+ end=+}+ contains=@iscExpression
syntax region iscTemplateInterpolation contained matchgroup=iscInterpolationDelim start=+\${+ end=+}+ contains=@iscExpression
syntax region iscFStringInterpolation contained matchgroup=iscInterpolationDelim start=+{+ end=+}+ contains=@iscExpression

syntax match iscComment "#.*$" contains=iscTodo,@Spell
syntax region iscCommentBlock start="/\*" end="\*/" contains=iscTodo,@Spell
syntax match iscCommentLine "//.*$" contains=iscTodo,@Spell

syntax keyword iscTodo TODO FIXME XXX NOTE HACK contained

syntax match iscFunction "\v<\w+\s*\ze\(" nextgroup=iscParens
syntax match iscClass "\v<class\s+\zs\w+" nextgroup=iscParens skipwhite
syntax match iscDefFunction "\v<def\s+\zs\w+" nextgroup=iscParens skipwhite
syntax match iscAsyncFunction "\v<async\s+def\s+\zs\w+" nextgroup=iscParens skipwhite

syntax match iscDecorator "@\w\+" nextgroup=iscParens skipwhite
syntax match iscDecoratorDot "@\w\+\.\w\+" nextgroup=iscParens skipwhite

syntax match iscOperatorSymbol "\v[\+\-\*/%\=\<\>\!\&\|\^\~]"
syntax match iscOperatorSymbol "\v(\=\=\=?|\!\=\=?|\<\=|\>\=|\&\&|\|\||[\+\-\*/%]\=|\*\*|//|\<\<|\>\>)"
syntax match iscArrow "\v\=\>"
syntax match iscArrow "\v-\>"

syntax match iscBracket "[\[\]{}()]"
syntax match iscColon ":"
syntax match iscComma ","
syntax match iscSemicolon ";"
syntax match iscDot "\."
syntax match iscQuestion "?"

syntax match iscMethod "\v\.\zs\w+\ze\(" nextgroup=iscParens
syntax match iscProperty "\v\.\zs\w+"
syntax match iscAttribute "\v\.\zs\w+\ze\s*\="

syntax match iscConstant "\v<[A-Z_][A-Z0-9_]+>"
syntax match iscConstantJS "\v<[A-Z][A-Z0-9_]*>"

syntax match iscClassVar "\v<\u\w+>"

syntax match iscSpecialVar "\v<__(init|new|del|repr|str|call|len|getitem|setitem|iter|next|enter|exit)__>"

syntax match iscMagicMethod "\v\.\zs__(init|new|del|repr|str|call|len|getitem|setitem|iter|next|enter|exit)__\ze\("

syntax match iscImportModule "\v<(import|from)\s+\zs\w+(\.\w+)*"
syntax match iscImportAs "\v<as\s+\zs\w+"

syntax match iscLambdaArrow "\v<lambda\s+.*\zs:"

syntax match iscSpread "\.\.\." contained
syntax match iscRest "\*\w\+" contained
syntax match iscDoubleRest "\*\*\w\+" contained

syntax region iscParens matchgroup=iscBracket start="(" end=")" contains=@iscExpression
syntax region iscBrackets matchgroup=iscBracket start="\[" end="\]" contains=@iscExpression
syntax region iscBraces matchgroup=iscBracket start="{" end="}" contains=@iscExpression

syntax cluster iscExpression contains=iscNumber,iscHex,iscOctal,iscBinary,iscString,iscTemplate,iscFString,iscBoolean,iscFunction,iscMethod,iscProperty,iscOperatorSymbol,iscArrow,iscBracket,iscColon,iscComma,iscDot,iscKeyword,iscKeywordJS,iscBuiltin,iscBuiltinJS,iscOperator,iscSelf,iscConstant,iscComment,iscCommentLine,iscCommentBlock,iscParens,iscBrackets,iscBraces,iscLambdaArrow,iscSpread,iscRest,iscDoubleRest

highlight default link iscKeyword Keyword
highlight default link iscKeywordJS Keyword
highlight default link iscAsync Special
highlight default link iscBuiltin Function
highlight default link iscBuiltinJS Type
highlight default link iscBoolean Boolean
highlight default link iscOperator Operator
highlight default link iscSelf Special
highlight default link iscException Exception
highlight default link iscNumber Number
highlight default link iscHex Number
highlight default link iscOctal Number
highlight default link iscBinary Number
highlight default link iscString String
highlight default link iscTemplate String
highlight default link iscFString String
highlight default link iscMultilineString String
highlight default link iscStringEscape SpecialChar
highlight default link iscStringInterpolation Special
highlight default link iscTemplateInterpolation Special
highlight default link iscFStringInterpolation Special
highlight default link iscInterpolationDelim Delimiter
highlight default link iscComment Comment
highlight default link iscCommentBlock Comment
highlight default link iscCommentLine Comment
highlight default link iscTodo Todo
highlight default link iscFunction Function
highlight default link iscClass Type
highlight default link iscDefFunction Function
highlight default link iscAsyncFunction Function
highlight default link iscDecorator PreProc
highlight default link iscDecoratorDot PreProc
highlight default link iscOperatorSymbol Operator
highlight default link iscArrow Operator
highlight default link iscBracket Delimiter
highlight default link iscColon Delimiter
highlight default link iscComma Delimiter
highlight default link iscSemicolon Delimiter
highlight default link iscDot Operator
highlight default link iscQuestion Operator
highlight default link iscMethod Function
highlight default link iscProperty Identifier
highlight default link iscAttribute Identifier
highlight default link iscConstant Constant
highlight default link iscConstantJS Constant
highlight default link iscClassVar Type
highlight default link iscSpecialVar Special
highlight default link iscMagicMethod Special
highlight default link iscImportModule Include
highlight default link iscImportAs Identifier
highlight default link iscLambdaArrow Operator
highlight default link iscSpread Operator
highlight default link iscRest Operator
highlight default link iscDoubleRest Operator

let b:current_syntax = "indentscript"

let &cpo = s:cpo_save
unlet s:cpo_save
