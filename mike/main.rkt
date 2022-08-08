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

(require racket/cmdline
         (only-in racket/vector vector-empty?)
         (only-in racket/string string-contains? string-prefix?)
         "private/rules.rkt")


(module+ main
  (command-line
   #:program "mike"

   #:ps
   ""
   "Copyright (c) 2021, Maciej Barć <xgqt@riseup.net>"
   "Licensed under the GNU GPL v3 License"

   #:multi
   [("-R" "--rules") "Display the defined rules" (display-rules)]
   [("-V" "--variables") "Display the defined variables" (display-variables)]

   #:args args
   (cond
     [(vector-empty? (current-command-line-arguments))
      ;; If no command-line arguments (or flags) are given,
      ;; then run the "compile" target
      ((hash-ref
        rules
        "compile"
        (lambda ()
          (error 'oops "No rule for target: \"compile\"! Bug in code?"))))]
     [else
      ;; For provided ARGS
      (let ([targets '()])
        (for ([arg args])
          (cond
            ;; VARIABLE assignment
            [(string-contains? arg "=") (set-variable arg)]
            ;; we can detect flags (ie.: -f / --f)
            [(string-prefix? arg "-") (append-variable "RUN_FLAGS" arg)]
            [else
             ;; Error if wanted target does not exists
             (hash-ref-key
              rules
              arg
              (lambda ()
                (error 'oops "No rule for target: ~a" arg)))
             ;; add ARG to TARGETS that user wants to execute
             (set! targets (append targets `(,arg)))]))
        (for ([target targets])
          ((hash-ref rules
                     target
                     (lambda ()
                       (error 'oops "BUG IN CODE?"))))))])))
