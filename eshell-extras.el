;;; eshell-extras.el --- Extras for eshell

;; Copyright (C) 2017 Matthew Bauer
;; Author: Matthew Bauer <mjbauer95@gmail.com>
;; Git: https://github.com/matthewbauer/eshell-extras
;; Version: 0.01
;; Created: 2017-06-05
;; Keywords: eshell, prompt

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This library provides utilities for working with directories in eshell.  They
;; aim to make eshell integrate into Emacs better.

;; This makes eshell’s cd behave like dired where each new directory is a new buffer.

;; Installation

;; It is recommended to install this as a package.
;; Type M-x followed by:
;; package-install<RET>eshell-extras

;; Usage

;; use-package:
;; (use-package eshell-extras
;;   :after eshell)

;;; Code:

(require 'eshell)
(require 'em-dirs)
(require 'hook-helpers)

(defgroup eshell-extras nil
  "Eshell extras"
  :group 'eshell)

;; (setq eshell-new-buffer-name nil)

;; (defun eshell-new (&rest args)
;;   "Load a new eshell for the current directory.
;; ARGS anything else Eshell needs."
;;   (setq-local eshell-buffer-name (concat "*eshell<" (expand-file-name default-directory) ">*")))

;; (advice-add 'eshell :before 'eshell-new)

(defun eshell-new (f &rest args)
  "Load a new eshell for the current directory.
F original eshell.
ARGS anything else Eshell needs."
  (let ((eshell-buffer-name (concat "*eshell<" (expand-file-name default-directory) ">*")))
    (apply f args)))

(advice-add 'eshell :around 'eshell-new)

(defun eshell/cd (&rest args)
  "Open each directory in a new buffer like dired.
ARGS to open if none provided assume HOME dir."
  (let* ((path (car (eshell-flatten-list args)))
         (curdir (eshell/pwd))
         (newdir (or path "~")))
    (unless (equal curdir newdir)
      (let ((default-directory (concat (expand-file-name newdir curdir) "/")))
        (if (file-directory-p default-directory)
            (let ((buffer
                   (get-buffer-create
                    (concat "*eshell<" default-directory ">*"))))
              (pop-to-buffer-same-window buffer)
              (unless (derived-mode-p 'eshell-mode)
                (eshell-mode)))
          (error "%s is not a directory" default-directory))))
    (run-hooks 'eshell-directory-change-hook)
    nil))
(put 'eshell/cd 'eshell-no-numeric-conversions t)

(define-hook-helper eshell-mode ()
  (define-key eshell-mode-map [(control ?u)] nil))

(require 'em-rebind)
(defun eshell-backward-kill-word (arg)
  "Delete the last word, unless it's part of the output.
ARG number of words to kill."
  (interactive "p")
  (let ((word-point (save-excursion (forward-word (- arg)) (point))))
    (if (eshell-point-within-input-p word-point)
	(backward-kill-word arg)
      (beep))))

(add-to-list 'eshell-rebind-keys-alist
             '([(control backspace)] . eshell-backward-kill-word))
(add-to-list 'eshell-rebind-keys-alist
             '([(meta backspace)] . eshell-backward-kill-word))
(add-to-list 'eshell-rebind-keys-alist
             '([(control delte)] . eshell-backward-kill-word))
(add-to-list 'eshell-rebind-keys-alist
             '([(meta delete)] . eshell-backward-kill-word))
;; (add-to-list 'eshell-rebind-keys-alist
;;              '([(backspace)] . eshell-delete-backward-char))
;; (add-to-list 'eshell-rebind-keys-alist
;;              '([(delete)] . eshell-delete-backward-char))

(provide 'eshell-extras)
;;; eshell-extras.el ends here