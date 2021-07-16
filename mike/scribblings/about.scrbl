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


@title[#:tag "mike-about"]{About}


I used to use @link["https://www.gnu.org/software/make/" "GNU Make"]
to speed up development of my Racket projects.
I started generalizing the
@link["https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html"
      "Makefiles"]
and my project layout to make it so
I could use the same Makefile in many projects
and with known to me commands (targets).

But then, I thought that it's not ideal to include a file in each of my projects
that would be mostly the same. So, I decided to, in the spirit of Racket,
rewrite Make in Racket but make it do only what my Makefile used to do.

The Makefile I used to use can be found left over in my projects or in the
@link["https://gitlab.com/xgqt/s-exp/-/blob/master/buildsystems/Makefile"
      "s-exp"]
project repository. That file is released into the
@link["https://creativecommons.org/share-your-work/public-domain/"
      "Public Domain"]
(or under
@link["https://spdx.org/licenses/CC0-1.0.html" "CC0-1.0"]
if your country does not have
@link["https://en.wikipedia.org/wiki/Public_domain" "Public Domain"]).


@section{Quickstart}


@subsection{Raco}

Install @link["https://gitlab.com/xgqt/racket-mike" "Racket-Mike"]
from remote
@link["https://pkgs.racket-lang.org/package/mike" "Racket package catalog"]
by executing:
@commandline{raco pkg install mike}

If you have cloned the repository instead use:
@commandline{raco pkg install --name mike}


@subsection{Mike}

If you want to install @exec{mike} via itself
(from within the cloned repository):
@commandline{racket ./mike/main.rkt PACKAGE_NAME=mike install setup}

or if you already have @exec{mike} installed and you wish to update it:
@commandline{git pull}
@commandline{mike PACKAGE_NAME=mike reinstall setup}


@subsection{Exe}

Another way to use @exec{mike} is to create a executable binary from itself
and then put it in a directory included in @envvar{PATH},
ie.: @filepath{/usr/bin}
@commandline{racket ./mike/main.rkt PACKAGE_NAME=mike clean exe}
@commandline{sudo cp ./bin/mike /usr/bin}


@subsection{PATH}

After installation make sure the launcher of @exec{mike}
is available in a directory included in your @envvar{PATH}.

You can also launch @exec{mike} with @exec{racket}
using @Flag{-l}/@Flag{--lib} flag.

Examples:
@commandline{racket -l mike/main -- -h}
@commandline{racket -l mike -- clean}


@section{Upstream}

The upstream repository can be found on
@link["https://gitlab.com/xgqt/racket-mike" "GitLab"].


@section{License}

Racket-Mike is released under GNU GPL, version 3 (only) license.

Read the
@link["https://spdx.org/licenses/GPL-3.0-only.html" "license text here"].
