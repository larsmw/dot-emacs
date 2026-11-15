# My dot-emacs

I am using a home compiled emacs with the following configure cmd:

```
sudo apt-get install git build-essential autoconf texinfo libpng-dev libwxgtk3.2-dev libx11-dev libxpm-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev ```
```
```
libgtk2.0-dev libncurses-dev libgnutls28-dev libgtk-3-dev
../emacs/configure --prefix=${HOME}/opt/emacs --bindir=${HOME}/opt/bin --with-tree-sitter --with-x --without-pop
```

## Keyboard shortcuts

Custom bindings set up in `.emacs.d/config`. Where a key copies PhpStorm, the
PhpStorm equivalent is listed. `C-h B` (embark) lists every binding active in
the current buffer.

### Navigation and search

| Key | Action | PhpStorm |
|---|---|---|
| `C-f` | Find file in project (projectile) | Ctrl+Shift+N |
| `C-c p` | Projectile command prefix | |
| `M-1` | Toggle project tree (treemacs) | Alt+1 |
| `C-x b` | Switch buffer (consult) | Ctrl+E |
| `C-x C-j` | Open dired at the current file | |
| `C-s` | Search lines in buffer (consult) | Ctrl+F |
| `M-s r` / `C-S-f` | Ripgrep the project (`C-S-f` works in GUI only) | Ctrl+Shift+F |
| `M-s f` | Find file by name | |
| `M-g g` | Go to line | Ctrl+G |
| `M-g i` / `C-<f12>` | File structure (imenu) | Ctrl+F12 |
| `M-y` | Browse kill ring | Ctrl+Shift+V |
| `C-.` | Act on thing at point (embark) | |
| `DEL` after `/` in a file prompt | Delete the whole last folder name | |
| `M-DEL` in a file prompt | Delete one folder name at a time | |

Completion prompts (`M-x`, `C-f`, `C-x b`, ...) match fuzzily: `evab` finds
`eval-buffer`, `phptl` finds `php-tools.el`. Space-separated words match in
any order. Results are sorted by recent use, then length.

### Code intelligence (eglot / LSP)

| Key | Action | PhpStorm |
|---|---|---|
| `M-.` | Go to definition (built in) | Ctrl+B |
| `M-,` | Jump back (built in) | Ctrl+Alt+Left |
| `M-<f7>` | Find usages | Alt+F7 |
| `M-RET` / `C-c l a` | Code actions / quick fix | Alt+Enter |
| `S-<f6>` / `C-c l r` | Rename symbol | Shift+F6 |
| `C-M-l` | Reformat buffer (project fixer in PHP buffers) | Ctrl+Alt+L |
| `C-c l f` | Format buffer via the language server | |
| `C-c l i` | Go to implementation | Ctrl+Alt+B |
| `C-c l t` | Go to type definition | |
| `C-c l s` | Search symbols across the project | Ctrl+Alt+Shift+N |
| `C-c l d` / `M-g f` | List diagnostics (flymake) | |
| `C-c l R` | Reconnect the language server | |

The PHP language server is phpactor (needs PHP on the host). It gives rename,
implementations and code actions for free, and shows PHPStan, php-cs-fixer and
phpcs problems inline when the project has them installed and configured.
intelephense is the fallback; switch with `M-x my/php-use-language-server` or
`C-u M-x eglot`. With intelephense, rename, implementations and code actions
need a licence in `~/.config/intelephense/licence.txt`.

### Editing

| Key | Action | PhpStorm |
|---|---|---|
| `C->` / `C-<` | Add cursor at next / previous match | Alt+J |
| `C-c C-<` | Add cursors at all matches | Ctrl+Alt+Shift+J |
| `M-S-<mouse-1>` | Add cursor on click | Alt+Shift+Click |
| `C-x +` / `C-x -` | Unfold / fold code block | Ctrl+= / Ctrl+- |

### PHP buffers

| Key | Action | PhpStorm |
|---|---|---|
| `C-c m` | PHP menu (tests, PHPStan, code style, Composer, debugging) | |
| `C-S-<f10>` | Run test at point (or the file if outside a test) | Ctrl+Shift+F10 |
| `S-<f10>` | Rerun last test run | Shift+F10 |
| `C-M-l` | Fix code style with the project's php-cs-fixer/phpcbf (on the host if PHP is installed), else the language server | Ctrl+Alt+L |

Inside `C-c m`: `t` test at point, `f` test file, `a` all tests, `l` rerun,
`s` PHPStan project, `S` PHPStan this file, `x` fix code style, `m` move class
(updates all references), `y` copy class, `L` switch language server,
`c` composer, `d` start listening for Xdebug, `q` stop debugging.

### Debugging (dape / Xdebug)

| Key | Action | PhpStorm |
|---|---|---|
| `C-<f8>` / click the fringe | Toggle breakpoint | Ctrl+F8 |
| `<f7>` | Step into | F7 |
| `<f8>` | Step over | F8 |
| `S-<f8>` | Step out | Shift+F8 |
| `<f9>` | Resume | F9 |
| `C-<f2>` | Stop debugging | Ctrl+F2 |
| `C-x C-a` | dape command prefix | |

### Git

| Key | Action |
|---|---|
| `C-x g` | Magit status |
| `C-c g` | Diff current file |
