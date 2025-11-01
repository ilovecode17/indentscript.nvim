# indentscript.nvim

Advanced syntax highlighting and tooling for IndentScript in Neovim.

## Features

- **Advanced Syntax Highlighting**
  - Python-style keywords (`def`, `class`, `for`, etc.)
  - JavaScript keywords (`function`, `const`, `let`, etc.)
  - F-strings with interpolation highlighting
  - Template literals
  - Decorators
  - Built-in functions and methods
  - Operators and delimiters
  - Comments (single-line and multi-line)

- **Automatic Indentation**
  - Smart indentation based on context
  - Proper handling of colons and blocks
  - Tab/space conversion

- **Code Formatting**
  - One-command buffer formatting
  - Configurable indent size
  - Auto-format on save (optional)

- **Linting**
  - Syntax error detection
  - Indentation warnings
  - Missing colons detection
  - Auto-lint on save (optional)

- **Integration**
  - Direct transpilation from Neovim
  - Execute IndentScript files
  - Real-time error reporting

- **Code Folding**
  - Indent-based folding
  - Function and class folding
  - Configurable fold levels

- **Completion**
  - Keyword completion
  - Built-in function completion
  - Smart completion based on context

## Installation 

# via vim-plug (Recommend)

```
Plug 'ilovecode17/indentscript.nvim'
```

## File Structure

```
indentscript.nvim/
├── plugin/
│   └── indentscript.vim
├── ftdetect/
│   └── indentscript.vim
├── syntax/
│   └── indentscript.vim
├── indent/
│   └── indentscript.vim
├── ftplugin/
│   └── indentscript.vim
├── doc/
│   └── indentscript.txt
└── README.md
```

### Create these files:

**`ftdetect/indentscript.vim`:**
```vim
autocmd BufNewFile,BufRead *.isc setfiletype indentscript
```

**`syntax/indentscript.vim`:**
```vim
if exists("b:current_syntax")
  finish
endif

runtime! plugin/indentscript.vim

let b:current_syntax = "indentscript"
```

**`indent/indentscript.vim`:**
```vim
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetIndentScriptIndent()
setlocal indentkeys+=0):,0],0},!^F,o,O,e
setlocal indentkeys-=0#
setlocal nosmartindent

function! GetIndentScriptIndent()
  let line = getline(v:lnum)
  let prevline = getline(v:lnum - 1)
  
  if prevline =~ ':\s*$'
    return indent(v:lnum - 1) + &sw
  endif
  
  if line =~ '^\s*\(else\|elif\|except\|finally\):'
    return indent(v:lnum - 1) - &sw
  endif
  
  return indent(v:lnum - 1)
endfunction
```

**`ftplugin/indentscript.vim`:**
```vim
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal commentstring=#%s
setlocal comments=:#
setlocal formatoptions-=t
setlocal formatoptions+=croql
setlocal suffixesadd=.isc
setlocal includeexpr=substitute(v:fname,'\\.','/','g')

let b:undo_ftplugin = "setl cms< com< fo< sua< inex<"
```

## Configuration

### Basic Configuration

Add to your `init.vim` or `init.lua`:

**Vimscript:**
```vim
let g:indentscript_indent_size = 4
let g:indentscript_auto_format = 0
let g:indentscript_auto_lint = 1
let g:indentscript_executable = 'node indentscript.js'
```

**Lua:**
```lua
vim.g.indentscript_indent_size = 4
vim.g.indentscript_auto_format = false
vim.g.indentscript_auto_lint = true
vim.g.indentscript_executable = 'node indentscript.js'
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `g:indentscript_indent_size` | `4` | Number of spaces per indent level |
| `g:indentscript_auto_format` | `0` | Auto-format on save |
| `g:indentscript_auto_lint` | `1` | Auto-lint on save |
| `g:indentscript_executable` | `'node indentscript.js'` | Path to IndentScript executable |

## Commands

| Command | Description |
|---------|-------------|
| `:ISCFormat` | Format the current buffer |
| `:ISCLint` | Lint the current buffer |
| `:ISCTranspile` | Transpile to JavaScript |
| `:ISCExecute` | Execute the current file |

## Key Mappings

Default key mappings (in `.isc` files):

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>if` | `:ISCFormat` | Format buffer |
| `<leader>il` | `:ISCLint` | Lint buffer |
| `<leader>it` | `:ISCTranspile` | Transpile to JS |
| `<leader>ie` | `:ISCExecute` | Execute file |

### Custom Mappings

Add custom mappings to your config:

```vim
autocmd FileType indentscript nnoremap <buffer> <F5> :ISCExecute<CR>
autocmd FileType indentscript nnoremap <buffer> <F6> :ISCTranspile<CR>
autocmd FileType indentscript nnoremap <buffer> <F7> :ISCFormat<CR>
autocmd FileType indentscript nnoremap <buffer> <F8> :ISCLint<CR>
```

## Usage Examples

### Basic Workflow

1. Create a new IndentScript file:
```vim
:e myapp.isc
```

2. Write your code with syntax highlighting

3. Format the code:
```vim
:ISCFormat
```

4. Check for errors:
```vim
:ISCLint
```

5. Transpile to JavaScript:
```vim
:ISCTranspile
```

6. Or execute directly:
```vim
:ISCExecute
```

### Advanced Usage

Enable auto-format and auto-lint:
```vim
let g:indentscript_auto_format = 1
let g:indentscript_auto_lint = 1
```

Use custom IndentScript path:
```vim
let g:indentscript_executable = '/usr/local/bin/indentscript'
```

## Syntax Highlighting Examples

### Keywords
```python
def function_name(param):
    if condition:
        return value
    else:
        pass
```

### Classes
```python
class MyClass:
    def __init__(self, value):
        this.value = value
```

### F-Strings
```python
name = "Alice"
print(f"Hello, {name}!")
```

### Async/Await
```python
async def fetch_data():
    result = await api_call()
    return result
```

### Decorators
```python
@staticmethod
def static_method():
    return "static"
```

## Troubleshooting

### Syntax highlighting not working

1. Check filetype:
```vim
:set filetype?
```

Should return `filetype=indentscript`

2. Manually set filetype:
```vim
:set filetype=indentscript
```

3. Reload syntax:
```vim
:syntax clear
:syntax on
```

### IndentScript executable not found

Set the correct path:
```vim
let g:indentscript_executable = '/path/to/indentscript'
```

Or add to PATH:
```bash
export PATH=$PATH:/path/to/indentscript/directory
```

### Indentation not working

1. Check indent settings:
```vim
:set indentexpr?
:set indentkeys?
```

2. Reset indentation:
```vim
:set indentexpr=GetIndentScriptIndent()
```

## Integration with LSP

For enhanced features, integrate with Neovim's built-in LSP:

```lua
require('lspconfig').indentscript.setup{
  cmd = {'node', 'indentscript.js', '--lsp'},
  filetypes = {'indentscript'},
  root_dir = require('lspconfig').util.root_pattern('.git'),
}
```

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub.

## License

MIT License
---

**Made with ❤️ in America 🇺🇸**
