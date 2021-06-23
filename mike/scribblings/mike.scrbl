#!/usr/bin/env racket


;; This file is part of racket-mike.

;; racket-mike is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, version 3.

;; racket-mike is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with racket-mike.  If not, see <https://www.gnu.org/licenses/>.

;; Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>
;; Licensed under the GNU GPL v3 License
;; SPDX-License-Identifier: GPL-3.0-only


#lang scribble/manual


@title[#:tag "mike"]{Mike}

@author[@author+email["Maciej Barć" "xgqt@riseup.net"]]


@table-of-contents[]


@section{About}

I used to use @link["https://www.gnu.org/software/make/" "GNU Make"]
to speed up development of my Racket projects.
I started generalizing the
@link["https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html"
      "Makefiles"]
and my project layout to make it so
I could use the same Makefile in many projects
and with known to me commands (targets).

But then I thought that it's not ideal to include a file in each of my projects
that would be mostly the same. So, I decided to, in the spirit of Racket,
rewrite Make in Racket, but make it do only what my Makefile used to do.

The Makefile I used to use can be found left over in my projects or in the
@link["https://gitlab.com/xgqt/s-exp/-/blob/master/buildsystems/Makefile"
      "s-exp"]
project repository. That file is released into the Public Domain
(or under CC0 if your country does not have Public Domain).


@subsection{Quickstart}


@subsubsection{Raco}

Install @link["https://gitlab.com/xgqt/racket-mike" "Racket-Mike"]
from remote
@link["https://pkgs.racket-lang.org/package/mike" "Racket package catalog"]
by executing:
@commandline{raco pkg install mike}

If you have cloned the repository instead use:
@commandline{raco pkg install --name mike}
or if you want to install @exec{mike} via itself:
@commandline{racket ./mike/main.rkt PACKAGE_NAME=mike install setup}


@subsubsection{PATH}

After installation make sure the launch of @exec{mike}
is available in your @envvar{PATH}.


@subsubsection{Exe}

Another way to use @exec{mike} is to create a executable binary from itself
and then put it somewhere in @envvar{PATH}, ie.: @filepath{/usr/bin}
@commandline{racket ./mike/main.rkt PACKAGE_NAME=mike clean exe}
@commandline{sudo cp ./bin/mike /usr/bin}


@subsection{Upstream}

The upstream repository can be found on
@link["https://gitlab.com/xgqt/racket-mike" "GitLab"].


@subsection{License}

Racket-Mike is released under GNU GPL, version 3 (only) license.


@section{Supported project structure}

The way I structure projects is that the package root is the repository root
and the pkg is a multi-collection package.

The @envvar{PACKAGE_NAME} variable is initially the same
as the name of project directory.

If the package has a CLI (command-line interface) the file
to run that interface should be named
@filepath{PACKAGE_NAME/main.rkt}
(controlled by the @envvar{ENTRYPOINT} variable).

Generated binary (@exec{exe} target) appears in bin directory
and documentation in @exec{doc} (@exec{docs} target).

Scribblings are in @filepath{PACKAGE_NAME/scribblings} direcotry
and the main scribble file is named @filepath{PACKAGE_NAME.scrbl}.


@section{Command-line interface}


@subsection{Variables}

@italic{Variables} are used to control how @italic{rules} execute,
for example a rule can contain
a variable @envvar{EXE_FLAGS} which determines command-line arguments
passed to
@link["https://docs.racket-lang.org/raco/exe.html?q=raco%20exe" "raco"]
in order to produce a binary executable.

Any initial variable can be overwritten by changing (exporting)
the system environment variables (ie.: export @envvar{ASD=fgh})
or passing the variables as one of the arguments (after options).

Options passed as arguments have precedence over environment variables.
In fact when overwriting using the environment variable route
the exported variables become initial variables.

Example: overwriting with environment

@commandline{export PACKAGE_NAME=asd}
@commandline{mike exe}

or

@commandline{PACKAGE_NAME=asd mike exe}

Example: overwriting with arguments

@commandline{mike PACKAGE_NAME=asd exe}


@subsection{Rules}

@italic{Rules} are the functions that define how @italic{targets} are handled.
@italic{Target} is a command-line argument that triggers
a @italic{rule} execution.

The rules can also be checked by entering into the @filepath{rules.rkt} modules
and executing @racket[(hash-keys rules)].

Any rule may be passed on the command-line.
Keep in mind that only if a variable is passed before target
the rule that target executes will have changed variables.

Example: @envvar{PACKAGE_NAME} is not overwritten

@commandline{mike exe PACKAGE_NAME=asd}

Example: @exec{compile} and @exec{exe} targets
will have different @envvar{PACKAGE_NAME}

@commandline{mike PACKAGE_NAME=asd compile PACKAGE_NAME=zxc exe}


@subsection{Available rules}

@subsubsection{Main}
@itemlist[
          @item{all - execute: install, setup & test}
          @item{compile - compile the @envvar{ENTRYPOINT}}
          @item{run - run the @envvar{ENTRYPOINT}}
          @item{install - install the package}
          ]

@subsubsection{Documentation}
@itemlist[
          @item{docs-dir - create the @exec{doc} directory}
          @item{docs-html - generate HTML documentation}
          @item{docs-latex - generate LaTex documentation}
          @item{docs-markdown - generate Markdown documentation}
          @item{docs-text - generate documentation in pure text format}
          @item{
                docs - execute:
                @exec{docs-html}, @exec{docs-latex}, @exec{docs-markdown}
                & @exec{docs-text}
                }
          ]

@subsubsection{Distribution}
@itemlist[
          @item{
                exe - create a executable in @filepath{bin} directory,
                from @envvar{ENTRYPOINT}
                }
          @item{pkg - create a source package}
          ]

@subsubsection{Removal}
@itemlist[
          @item{
                distclean - remove pkg zip (generated by @exec{pkg} target)
                & binary executable
                }
          @item{
                clean - execute: disclean & remove all @exec{compiled}
                and @exec{doc} directories
                }
          @item{remove - uninstall the package}
          @item{purge - execute: remove & clean}
          @item{reinstall - remove and install the package again}
          @item{resetup - execute: @exec{reinstall} & @exec{setup}}
          ]

@subsubsection{Tests}
@itemlist[
          @item{setup - run @exec{raco setup}}
          @item{check-deps - check package dependencies}
          @item{test-local - test locally (without installing the package)}
          @item{test - test installed package}
          ]

@subsubsection{Everything}
@itemlist[
          @item{show-rules - display available rules}
          @item{show-variables
                - display available variables (and what they are set to)}
          @item{show - execute both @exec{show-rules} & @exec{show-variables}}
          @item{
                everything-test - execute:
                @exec{clean}, @exec{compile}, @exec{install}, @exec{setup},
                @exec{check-deps}, @exec{test}, @exec{purge}
                }
          @item{everything-dist - execute: @exec{pkg} & @exec{exe}}
          ]
