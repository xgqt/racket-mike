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
 racket/cmdline
 racket/string
 racket/vector
 "private/rules.rkt"
 )


(module+ main
  (command-line
   #:program "mike"
   #:ps
   "Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>"
   "Licensed under the GNU GPL v3 License"
   #:multi
   [("-R" "--rules")     "Display the defined rules"     (display-rules)]
   [("-V" "--variables") "Display the defined variables" (display-variables)]
   #:args args
   (if (vector-empty? (current-command-line-arguments))
       ;; If no command-line arguments (or flags) are given,
       ;; then run the "compile" target
       (
        (hash-ref
         rules "compile"
         (lambda () (error 'oops "No rule for target: \"compile\"! Bug in code?"))
         )
        )
       ;; For non-flag arguments
       (for ([arg args])
         (if (string-contains? arg "=")
             ;; True - set variable
             (set-variable arg)
             ;; False - run rule
             (
              (hash-ref rules arg
                        (lambda () (error 'oops "No rule for target: ~a" arg)))
              )
             )
         )
       )
   )
  )
