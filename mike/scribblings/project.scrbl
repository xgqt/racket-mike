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


@title[#:tag "mike-project"]{Supported project structure}


The way I structure projects is that the package root is the repository root
(the directory holding te source code)
and the Racket package is a
@link["https://docs.racket-lang.org/pkg/Package_Concepts.html?q=%27multi#%28part._concept~3amulti-collection%29"
      "multi-collection package"].

The @envvar{PACKAGE_NAME} variable is initially the same
as the name of project directory.

If the package has a CLI (command-line interface) the file
to run that interface should be named
@filepath{PACKAGE_NAME/main.rkt}
(controlled by the @envvar{ENTRYPOINT} variable).

Generated binary (@exec{exe} target) appears in @filepath{bin} directory
and documentation in @exec{doc} (@exec{docs} target).

Scribblings are in @filepath{PACKAGE_NAME/scribblings} directory
and the main scribble file is named @filepath{PACKAGE_NAME.scrbl}.
