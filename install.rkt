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


#lang racket/base

(require
 pkg/lib
 "mike/private/rules.rkt"
 )


(module+ main
  ;; Uninstall if installed
  (when (member (PACKAGE_NAME) (installed-pkg-names))
    (announce (PACKAGE_NAME) "found, uninstalling" (PACKAGE_NAME) "...")
    (remove)
    )

  ;; Install
  (announce "Installing" (PACKAGE_NAME) "...")
  (install)
  )