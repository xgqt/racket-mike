# Mike

Maciej Barć <[xgqt@riseup.net](mailto:xgqt@riseup.net)>

    1 About                      
      1.1 Quickstart             
        1.1.1 Raco               
        1.1.2 Mike               
        1.1.3 Exe                
        1.1.4 PATH               
      1.2 Upstream               
      1.3 License                
                                 
    2 Supported project structure
      2.1 Entrypoint             
      2.2 Scribblings            
      2.3 Artifact directories   
                                 
    3 Command-line interface     
      3.1 Options                
      3.2 Variables              
      3.3 Rules                  
      3.4 Available rules        
        3.4.1 Main               
        3.4.2 Documentation      
        3.4.3 Distribution       
        3.4.4 Removal            
        3.4.5 Tests              
        3.4.6 Everything         

## 1. About

I used to use [GNU Make](https://www.gnu.org/software/make/) to speed up
development of my Racket projects. I started generalizing the
[Makefiles](https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html)
and my project layout to make it so I could use the same Makefile in
many projects and with known to me commands (targets).

But then, I thought that it’s not ideal to include a file in each of my
projects that would be mostly the same. So, I decided to, in the spirit
of Racket, rewrite Make in Racket but make it do only what my Makefile
used to do.

The Makefile I used to use can be found left over in my projects or in
the
[s-exp](https://gitlab.com/xgqt/s-exp/-/blob/master/buildsystems/Makefile)
project repository. That file is released into the [Public
Domain](https://creativecommons.org/share-your-work/public-domain/) \(or
under [CC0-1.0](https://spdx.org/licenses/CC0-1.0.html) if your country
does not have [Public
Domain](https://en.wikipedia.org/wiki/Public_domain)).

### 1.1. Quickstart

#### 1.1.1. Raco

Install [Racket-Mike](https://gitlab.com/xgqt/racket-mike) from remote
[Racket package catalog](https://pkgs.racket-lang.org/package/mike) by
executing:

  `raco pkg install mike`

If you have cloned the repository instead use:

  `raco pkg install --name mike`

#### 1.1.2. Mike

If you want to install `mike` via itself \(from within the cloned
repository\):

  `racket ./mike/main.rkt PACKAGE_NAME=mike install setup`

or if you already have `mike` installed and you wish to update it:

  `git pull`

  `mike PACKAGE_NAME=mike reinstall setup`

#### 1.1.3. Exe

Another way to use `mike` is to create a executable binary from itself
and then put it in a directory included in `PATH`, ie.: `"/usr/bin"`

  `racket ./mike/main.rkt PACKAGE_NAME=mike clean exe`

  `sudo cp ./bin/mike /usr/bin`

#### 1.1.4. PATH

After installation make sure the launcher of `mike` is available in a
directory included in your `PATH`.

You can also launch `mike` with `racket` using `--l`/`-–lib` flag.

Examples:

  `racket -l mike/main -- -h`

  `racket -l mike -- clean`

### 1.2. Upstream

The upstream repository can be found on
[GitLab](https://gitlab.com/xgqt/racket-mike).

### 1.3. License

Racket-Mike is released under GNU GPL, version 3 (only) license.

Read the [license text
here](https://spdx.org/licenses/GPL-3.0-only.html).

## 2. Supported project structure

The way I structure projects is that the package root is the repository
root \(the directory holding te source code\) and the Racket package is
a [multi-collection
package](https://docs.racket-lang.org/pkg/Package_Concepts.html?q=%27multi#%28part._concept~3amulti-collection%29).

The `PACKAGE_NAME` variable is initially the same as the name of project
directory.

### 2.1. Entrypoint

If the package has a CLI (command-line interface) the file to run that
interface should be named `"PACKAGE_NAME/main.rkt"` \(controlled by the
`ENTRYPOINT` variable).

### 2.2. Scribblings

Scribblings are in `"PACKAGE_NAME/scribblings"` directory and the main
scribble file is named `"PACKAGE_NAME.scrbl"`.

### 2.3. Artifact directories

Generated binary (`exe` target) appears in `"bin"` directory and
documentation in `doc` (`docs` target).

## 3. Command-line interface

### 3.1. Options

Options must come before _variables_ and _targets_, so they can not be
overwritten by setting any _variables_. They can only be overwritten by
executing `mike` with wanted variables exported to system environment
beforehand.

`mike` command accepts the following command-line flags:

* `--R` or `--rules` — display available rules, the same as executing
  the `show-rules` target

* `--V` or `--variables` — display available variables (and what they
  are set to), the same as executing the `show-variables` target

### 3.2. Variables

_Variables_ are used to control how _rules_ execute, for example a rule
can contain a variable `EXE_FLAGS` which determines command-line
arguments passed to
[raco](https://docs.racket-lang.org/raco/exe.html?q=raco%20exe) in order
to produce a binary executable.

Any initial variable can be overwritten by changing (exporting) the
system environment variables (ie.: export `ASD=fgh`) or passing the
variables as one of the arguments (after options).

Variables overwriting passed as arguments have precedence over
environment variables. In fact when overwriting using the environment
variable route the exported variables become initial variables.

Example: overwriting with environment

  `export PACKAGE_NAME=asd`

  `mike exe`

or

  `PACKAGE_NAME=asd mike exe`

Example: overwriting with arguments

  `mike PACKAGE_NAME=asd exe`

### 3.3. Rules

_Rules_ are the functions that define how _targets_ are handled.
_Target_ is a command-line argument that triggers a _rule_ execution.

For developers: The rules can also be checked by entering into the
`"rules.rkt"` module and executing `(hash-keys rules)`.

Rules are first gathered and checked if they exist, if they do they are
executed in the order specified on the command-line, if they do not
exist an exception is raised and the program terminates. Because of this
it is impossible to have one target executed with one value of variable
and the other with a different value.

Example: `PACKAGE_NAME` will be "fgh"

  `mike PACKAGE_NAME=asd show-variables PACKAGE_NAME=fgh`

### 3.4. Available rules

#### 3.4.1. Main

* all — execute: install, setup & test

* compile — compile the `PWD` directory \(which is `(current-directory)`
  unless overwritten)

* run — run the `ENTRYPOINT`

* install — install the package

#### 3.4.2. Documentation

* docs-dir — create the `doc` directory

* docs-html — generate HTML documentation

* docs-latex — generate LaTex documentation

* docs-markdown — generate Markdown documentation

* docs-text — generate documentation in pure text format

* docs — execute: `docs-html`, `docs-latex`, `docs-markdown` &
  `docs-text`

#### 3.4.3. Distribution

* exe — create a executable in `"bin"` directory, from `ENTRYPOINT`

* pkg — create a source package

#### 3.4.4. Removal

* distclean — remove pkg zip (generated by `pkg` target) & binary
  executable

* clean — execute: disclean & remove all `compiled` and `doc`
  directories

* remove — uninstall the package

* purge — execute: remove & clean

* reinstall — remove and install the package again

* resetup — execute: `reinstall` & `setup`

#### 3.4.5. Tests

* setup — run `raco setup`

* check-deps — check package dependencies

* test-local — test locally (without installing the package)

* test — test installed package

#### 3.4.6. Everything

* show-rules — display available rules

* show-variables — display available variables (and what they are set
  to)

* show — execute both `show-rules` & `show-variables`

* everything-test — execute: `clean`, `compile`, `install`, `setup`,
  `check-deps`, `test`, `purge`

* everything-dist — execute: `pkg` & `exe`
