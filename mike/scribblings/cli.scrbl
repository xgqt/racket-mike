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


@title[#:tag "mike-cli"]{Command-line interface}


@section{Options}

Options must come before @italic{variables} and @italic{targets},
so they can not be overwritten by setting any @italic{variables}.
They can only be overwritten by executing @exec{mike} with wanted variables
exported to system environment beforehand.

@exec{mike} command accepts the following command-line flags:

@itemlist[
 @item{
  @Flag{-R} or @DFlag{rules}
  --- display available rules,
  the same as executing the @exec{show-rules} target
 }
 @item{
  @Flag{-V} or @DFlag{variables}
  --- display available variables (and what they are set to),
  the same as executing the @exec{show-variables} target
 }
 ]


@section{Variables}

@italic{Variables} are used to control how @italic{rules} execute,
for example a rule can contain
a variable @envvar{EXE_FLAGS} which determines command-line arguments
passed to
@link["https://docs.racket-lang.org/raco/exe.html?q=raco%20exe" "raco"]
in order to produce a binary executable.

Any initial variable can be overwritten by changing (exporting)
the system environment variables (ie.: export @envvar{ASD=fgh})
or passing the variables as one of the arguments (after options).

Variables overwriting passed as arguments have precedence
over environment variables.
In fact when overwriting using the environment variable route
the exported variables become initial variables.

Example: overwriting with environment

@commandline{export PACKAGE_NAME=asd}
@commandline{mike exe}

or

@commandline{PACKAGE_NAME=asd mike exe}

Example: overwriting with arguments

@commandline{mike PACKAGE_NAME=asd exe}


@section{Rules}

@italic{Rules} are the functions that define how @italic{targets} are handled.
@italic{Target} is a command-line argument that triggers
a @italic{rule} execution.

For developers: The rules can also be checked by entering into the
@filepath{rules.rkt} module and executing @racket[(hash-keys rules)].

Rules are first gathered and checked if they exist,
if they do they are executed in the order specified on the command-line,
if they do not exist an exception is raised and the program terminates.
Because of this it is impossible to have one target executed with one value
of variable and the other with a different value.

Example: @envvar{PACKAGE_NAME} will be "fgh"

@commandline{mike PACKAGE_NAME=asd show-variables PACKAGE_NAME=fgh}


@section{Available rules}

@subsection{Main}
@itemlist[
 @item{all --- execute: install, setup & test}
 @item{
  compile --- compile the @envvar{PWD} directory
  (which is @racket[(current-directory)] unless overwritten)
 }
 @item{run --- run the @envvar{ENTRYPOINT}}
 @item{install --- install the package}
 ]

@subsection{Documentation}
@itemlist[
 @item{docs-dir --- create the @exec{doc} directory}
 @item{docs-html --- generate HTML documentation}
 @item{docs-latex --- generate LaTex documentation}
 @item{docs-markdown --- generate Markdown documentation}
 @item{docs-text --- generate documentation in pure text format}
 @item{
  docs --- execute:
  @exec{docs-html}, @exec{docs-latex}, @exec{docs-markdown}
  & @exec{docs-text}
 }
 ]

@subsection{Distribution}
@itemlist[
 @item{
  exe --- create a executable in @filepath{bin} directory,
  from @envvar{ENTRYPOINT}
 }
 @item{pkg --- create a source package}
 ]

@subsection{Removal}
@itemlist[
 @item{
  distclean --- remove pkg zip (generated by @exec{pkg} target)
  & binary executable
 }
 @item{
  clean --- execute: disclean & remove all @exec{compiled}
  and @exec{doc} directories
 }
 @item{remove --- uninstall the package}
 @item{purge --- execute: remove & clean}
 @item{reinstall --- remove and install the package again}
 @item{resetup --- execute: @exec{reinstall} & @exec{setup}}
 ]

@subsection{Tests}
@itemlist[
 @item{setup --- run @exec{raco setup}}
 @item{check-deps --- check package dependencies}
 @item{test-local --- test locally (without installing the package)}
 @item{test --- test installed package}
 ]

@subsection{Everything}
@itemlist[
 @item{show-rules --- display available rules}
 @item{
  show-variables
  --- display available variables (and what they are set to)
 }
 @item{
  show --- execute both @exec{show-rules} & @exec{show-variables}
 }
 @item{
  everything-test --- execute:
  @exec{clean}, @exec{compile}, @exec{install}, @exec{setup},
  @exec{check-deps}, @exec{test}, @exec{purge}
 }
 @item{everything-dist --- execute: @exec{pkg} & @exec{exe}}
 ]
