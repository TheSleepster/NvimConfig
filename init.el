(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))

(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)"))))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads"))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Install Evil and related packages
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init)
  :ensure t)

(use-package general
  :ensure t
  :config
  (general-evil-setup)

  ;; Leader key
  (general-create-definer dt/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  ;; Utilities
  (dt/leader-keys
   "b" '(:ignore t :wk "buffer")
   "bb" '(switch-to-buffer :wk "Switch to Buffer")
   "bi" '(ibuffer :wk "IBuffer")
   "bk" '(kill-this-buffer :wk "Kill this buffer")
   "bn" '(next-buffer :wk "Next buffer")
   "bp" '(previous-buffer :wk "Previous buffer")
   "br" '(reload-buffer :wk "Reload buffer"))

  (dt/leader-keys
    "h" '(:ignore t :wk "Help")
    "hf" '(describe-function :wk "Describe Function")
    "hv" '(describe-variable :wk "Describe Variable"))

  ;; Unbind the default action of C-d
  (general-define-key
   :states 'insert
   "C-d" nil)

  ;; Keybindings for brace insertion and duplication
  (general-define-key
    "C-z" 'insert-equals-braces
    "C-b" 'insert-allman-braces
    "C-s" 'insert-allman-braces-semicolon
    "C-c" 'insert-allman-braces-break
    "C-d" 'duplicate-line)
  ;; Keybindings for commenting
  (general-define-key
   :states '(normal visual)
   "gc" '(:ignore t :wk "Comment")
   "gcc" 'comment-line      ;; Comment out current line
   "gci" 'comment-region)   ;; Comment out selected region
  )

;; Functions for brace insertion
(defun insert-equals-braces ()
  (interactive)
  (insert "= {};"))

(defun insert-allman-braces ()
  (interactive)
  (insert "{\n\n}"))

(defun insert-allman-braces-semicolon ()
  (interactive)
  (insert "{\n\n};"))

(defun insert-allman-braces-break ()
  (interactive)
  (insert "{\n\n}break;"))

(defun duplicate-line ()
  "Duplicate the current line."
  (interactive)
  (save-excursion
    (let ((line (thing-at-point 'line t)))
      (move-beginning-of-line 1)
      (insert line))))

;; Ensure Company mode is installed and configured
(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0.2)           ;; Set a short delay for completions
  (setq company-minimum-prefix-length 1)  ;; Minimum prefix length for completions
  (setq company-show-numbers t)            ;; Show numbers for selection
  (setq company-tooltip-align-annotations t)  ;; Align annotations to the right
  (global-company-mode 1))                  ;; Enable Company mode globally

;; Configure Clangd arguments
(setq clangd-args '("--header-insertion=never" ;; Disable header insertion
                    "--all-tokens"))           ;; Include all tokens for completion

;; Define function to set up Clangd and apply custom configurations for C/C++ buffers
(defun my-eglot-setup ()
  (interactive)
  (eglot-ensure)
  ;; Set local eglot server programs for C/C++
  (setq-local eglot-server-programs
              '((c-mode . ("clangd" "--header-insertion=never" "--all-tokens"))
                (c++-mode . ("clangd" "--header-insertion=never" "--all-tokens"))))
  ;; Set ignored capabilities for eglot (e.g., disabling hover, etc.)
  (setq-local eglot-ignored-server-capabilities
              '(:hover :signatureHelp :documentHighlight
                       :codeActionProvider :documentFormattingProvider
                       :documentRangeFormattingProvider :documentSymbolProvider
                       :definitionProvider))
  ;; Disable eldoc mode for the buffer
  (eldoc-mode -1))

;; Add the custom setup to eglot-managed-mode-hook
(add-hook 'eglot-managed-mode-hook 'my-eglot-setup)

;; Hook to run Clangd setup specifically for C/C++ modes
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

;; Optionally disable global eldoc mode if you don't need it at all
(global-eldoc-mode -1)

;; GLSL Configuration with Eglot
(with-eval-after-load 'eglot
  (setq eglot-stay-out-of '(flymake))
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
  (add-to-list 'eglot-server-programs
               '(glsl-mode . ("C:/Users/ibjal/AppData/Local/nvim-data/mason/packages/glsl_analyzer/bin/glsl_analyzer.exe" "--stdio")))
  ;; Add additional file extensions for GLSL
  (add-to-list 'auto-mode-alist '("\\.\\(fs\\|vs\\|vert\\|frag\\|glsl\\)\\'" . glsl-mode)))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (message "Starting clangd with args: %s" lsp-clients-clangd-args)))

;; C# Configuration with Eglot
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(csharp-mode . ("C:/Users/ibjal/AppData/Local/nvim-data/mason/packages/omnisharp/OmniSharp.exe" "--stdio"))))

;; C/C++ mode setup
(add-hook 'c-mode-hook
          (lambda ()
            (eglot-ensure)
            (setq-local company-backends '(company-capf))
            (setq company-idle-delay 0.5)))

(add-hook 'c++-mode-hook
          (lambda ()
            (eglot-ensure)
            (setq-local company-backends '(company-capf))
            (setq company-idle-delay 0.5)))


;CONFIG

;; Suppress minibuffer messages
(setq echo-keystrokes 0.1)
(setq-default minibuffer-message-timeout 0)

;; Disable displaying help at point when idle
(setq help-at-pt-display-when-idle nil)

;; Adjust company-mode settings if needed
(setq company-tooltip-align-annotations t)
(setq company-show-numbers nil)
(setq company-idle-delay 0.5)

; Stop Emacs from losing undo information by
; setting very high limits for undo buffers
(setq compilation-directory-locked nil)
(scroll-bar-mode -1)
(setq shift-select-mode nil)
(setq enable-local-variables nil)

(setq giosupports-verbose nil)
(setq-default truncate-lines t)  ;; Enable line truncation
(setq-default word-wrap nil)  ;; Disable word wrapping

(setq sleepster-todo-file "w:/Clover/code/todo.txt")

(setq undo-limit 20000000)
(setq undo-strong-limit 40000000)


(global-hl-line-mode 1)
(set-face-background 'hl-line "midnight blue")


(setq evil-default-cursor 'box)
(setq evil-insert-state-cursor 'box)
(setq display-line-numbers-type nil)

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

(setq sleepster-buildscript "build.bat")
(setq compilation-directory-locked nil)

; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
(setq dabbrev-case-replace t)
(setq dabbrev-case-fold-search t)
(setq dabbrev-upcase-means-case-search t)

(add-to-list 'default-frame-alist '(font . "LiterationMono Nerd Font Propo-11"))
(setq-default line-spacing 0.12)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(require 'compile)
(abbrev-mode 1)

(defun load-todo ()
  (interactive)
  (find-file sleepster-todo-file)
)
(define-key global-map (kbd "<f2>") 'load-todo)


; no screwing with my middle mouse button
(global-unset-key [mouse-2])

;; Functions for TODO Inserts
;; Define a variable for the username
(defvar sleepster-username "Sleepster"
  "The username to be inserted in comments.")

;; Function to insert a comment with a given prefix
(defun insert-comment-with-prefix (prefix)
  "Insert a comment with PREFIX and the defined username."
  (interactive "sPrefix: ")  ;; Prompt for prefix
  (insert (format "// %s: " (concat prefix sleepster-username))))

;; Keybindings
(define-key global-map (kbd "M-t") (lambda () (interactive) (insert-comment-with-prefix "TODO(")))
(define-key global-map (kbd "M-y") (lambda () (interactive) (insert-comment-with-prefix "NOTE(")))

;; Function to insert current time of day and file name into the header
(defun sleepster-header-format ()
  (interactive)
  (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
  (insert "#if !defined(")
  (push-mark)
  (insert BaseFileName)
  (upcase-region (mark) (point))
  (pop-mark)
  (insert "_H)\n")
  (insert "/* ========================================================================\n")
  (insert (format "   $File: %s $\n" (file-name-nondirectory buffer-file-name)))
  (insert (format "   $Date: %s $\n" (format-time-string "%a, %d %b %y: %I:%M%p")))
  (insert "   $Revision: $\n")
  (insert "   $Creator: Justin Lewis $\n")
  (insert "   ======================================================================== */\n\n")
  (insert "#define ")
  (push-mark)
  (insert BaseFileName)
  (upcase-region (mark) (point))
  (pop-mark)
  (insert "_H\n")
  (insert "#endif"))

;; Function to insert current time of day and file name into the source
(defun sleepster-source-format ()
  (interactive)
  (setq BaseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
  (insert "/* ========================================================================\n")
  (insert (format "   $File: %s $\n" (file-name-nondirectory buffer-file-name)))
  (insert (format "   $Date: %s $\n" (format-time-string "%a, %d %b %y: %I:%M%p")))
  (insert "   $Revision: $\n")
  (insert "   $Creator: Justin Lewis $\n")
  (insert "   ======================================================================== */\n"))

 (setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
 (make-face 'font-lock-fixme-face)
 (make-face 'font-lock-note-face)
 (mapc (lambda (mode)
	 (font-lock-add-keywords
	  mode
	  '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
            ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))
	fixme-modes)
 (modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
 (modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)


(when buffer-file-name
  (cond ((file-exists-p buffer-file-name) t)
        ((string-match "\\.hin$" buffer-file-name) (sleepster-source-format))
        ((string-match "\\.cin$" buffer-file-name) (sleepster-source-format))
        ((string-match "\\.h$" buffer-file-name) (sleepster-header-format))
        ((string-match "\\.cpp$" buffer-file-name) (sleepster-source-format))))

;; Ensure the same file opens only in one window
(defun my-find-file (filename)
  "Open a file, ensuring it's opened in only one window."
  (interactive "FOpen file: ")
  (let ((buf (find-file-noselect filename)))
    (switch-to-buffer buf)
    (when (one-window-p)
      (display-buffer buf))))

;; Bind the function to a key or use it as a default
(global-set-key (kbd "C-x C-f") 'my-find-file)

;; SILLY FUN Find File Function
  (defun sleepster-find-corresponding-file ()
    "Find the file that corresponds to this one."
    (interactive)
    (setq CorrespondingFileName nil)
    (setq BaseFileName (file-name-sans-extension buffer-file-name))
    (if (string-match "\\.c" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if (string-match "\\.h" buffer-file-name)
       (if (file-exists-p (concat BaseFileName ".c")) (setq CorrespondingFileName (concat BaseFileName ".c"))
	   (setq CorrespondingFileName (concat BaseFileName ".cpp"))))
    (if (string-match "\\.hin" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".cin")))
    (if (string-match "\\.cin" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".hin")))
    (if (string-match "\\.cpp" buffer-file-name)
       (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if CorrespondingFileName (find-file CorrespondingFileName)
       (error "Unable to find a corresponding file")))
  (defun sleepster-find-corresponding-file-other-window ()
    "Find the file that corresponds to this one."
    (interactive)
    (find-file-other-window buffer-file-name)
    (sleepster-find-corresponding-file)
    (other-window -1))

  ; 4-space tabs
  (setq tab-width 4
        indent-tabs-mode nil)

  ; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
  (setq dabbrev-case-replace t)
  (setq dabbrev-case-fold-search t)
  (setq dabbrev-upcase-means-case-search t)

  ; Abbrevation expansion
  (abbrev-mode 1)

; 4-space tabs
(setq tab-width 4
    indent-tabs-mode nil)

; Additional style stuff
(c-set-offset 'member-init-intro '++)
(setq c-basic-offset 4)

; Handle super-tabbify (TAB completes, shift-TAB actually tabs)
(setq dabbrev-case-replace t)
(setq dabbrev-case-fold-search t)
(setq dabbrev-upcase-means-case-search t)

; Abbrevation expansion
(abbrev-mode 1)


;; SILLY FUN COMPILATION
  ; devenv.com error parsing
  (add-to-list 'compilation-error-regexp-alist 'sleepester-devenv)
  (add-to-list 'compilation-error-regexp-alist-alist '(sleepster-devenv
   "*\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:see declaration\\|\\(?:warnin\\(g\\)\\|[a-z ]+\\) C[0-9]+:\\)"
    2 3 nil (4)))

(setq compilation-context-lines 0)
(setq compilation-window-height nil)
(setq compilation-error-regexp-alist
    (cons '("^\\([0-9]+>\\)?\\(\\(?:[a-zA-Z]:\\)?[^:(\t\n]+\\)(\\([0-9]+\\)) : \\(?:fatal error\\|warnin\\(g\\)\\) C[0-9]+:" 2 3 nil (4))
     compilation-error-regexp-alist))

(defun sleepster-big-fun-compilation-hook ()
  (make-local-variable 'truncate-lines)
  (setq truncate-lines nil)
)

 (defun setup-msvc-env ()
   (interactive)
   (shell-command "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvarsall.bat x64"))

 (add-hook 'compilation-mode-hook 'setup-msvc-env)

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p sleepster-buildscript) t
      (cd "../")
      (find-project-directory-recursive)))

(defun lock-compilation-directory ()
  "The compilation process should NOT hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process SHOULD hunt for a makefile"
  (interactive)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun find-project-directory ()
  "Find the project directory."
  (interactive)
  (setq find-project-from-directory default-directory)
  (switch-to-buffer-other-window "*compilation*")
  (if compilation-directory-locked (cd last-compilation-directory)
  (cd find-project-from-directory)
  (find-project-directory-recursive)
  (setq last-compilation-directory default-directory)))

(defun my-display-compilation-in-opposite-window (buffer &optional _)
  "Display the compilation BUFFER in the opposite window."
  (let* ((left-window (window-at 0 0))
         (right-window (next-window left-window)))
    ;; Check if the current window is the left or right one
    (if (eq (selected-window) left-window)
        (set-window-buffer right-window buffer)
      (set-window-buffer left-window buffer))
    (select-window (selected-window))))  ;; Keep focus in the original window


(setq display-buffer-overriding-action
      '((my-display-compilation-in-opposite-window)))

(defun make-without-asking ()
  "Make the current build and return to the original buffer and position."
  (interactive)
  (let ((original-window (selected-window))
        (original-buffer (current-buffer))
        (original-point (point))
        (window-start-point (window-start)))
    (when (find-project-directory)
      (compile sleepster-buildscript))
    ;; Ensure the window focus is returned to the original window and point
    (select-window original-window)
    (set-window-start original-window window-start-point)
    (goto-char original-point)))

;; KEYMAPPINGS
(define-key global-map "\em" 'make-without-asking)
(define-key global-map "\en" 'next-error)
(define-key global-map "\ep" 'previous-error)
  (define-key global-map [f12] 'sleepster-find-corresponding-file)
  (define-key global-map [M-f12] 'sleepster-find-corresponding-file-other-window)

(defun maximize-frame()
  "Maximize the current frame"
  (interactive)
  (w32-send-sys-command 61488)
)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq auto-save-default nil)

(display-time)
(split-window-horizontally)
(setq auto-save-default nil
      auto-save-interval 0
      auto-save-list-file-prefix nil
      auto-save-timeout 0
      auto-show-mode t
      delete-auto-save-files nil
      delete-old-versions 'other
      imenu-auto-rescan t
      imenu-auto-rescan-maxout 500000
      kept-new-versions 5
      kept-old-versions 5
      make-backup-file-name-function 'ignore
      make-backup-files nil
      mouse-wheel-follow-mouse nil
      mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(15)
      version-control nil)

;; If you use org' and don't want your org files in the default location below,
;; change org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("3d39093437469a0ae165c1813d454351b16e4534473f62bc6e3df41bb00ae558" default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(load-theme 'handmade)
(add-to-list 'default-frame-alist '(font . "LiterationMono Nerd Font Propo-11"))
(set-face-attribute 'default t :font "LiterationMono Nerd Font Propo-11")
(set-face-attribute 'font-lock-builtin-face nil :foreground "#DAB98F")
(set-face-attribute 'font-lock-comment-face nil :foreground "gray50")
(set-face-attribute 'font-lock-constant-face nil :foreground "olive drab")
(set-face-attribute 'font-lock-doc-face nil :foreground "gray50")
(set-face-attribute 'font-lock-function-name-face nil :foreground "burlywood3")
(set-face-attribute 'font-lock-keyword-face nil :foreground "DarkGoldenrod3")
(set-face-attribute 'font-lock-string-face nil :foreground "olive drab")
(set-face-attribute 'font-lock-type-face nil :foreground "burlywood3")
(set-face-attribute 'font-lock-variable-name-face nil :foreground "burlywood3")
(set-face-attribute 'font-lock-function-call-face nil :foreground "DarkGoldenrod3")
(defun highlight-function-calls ()
  "Highlight function calls in C/C++ modes."
  (font-lock-add-keywords
   nil
   '(("\\<\\(\\w+\\)\\s-*(" 1 'font-lock-function-call-face))))

;; Hook into C/C++ modes
(add-hook 'c-mode-common-hook 'highlight-function-calls)

(defun post-load-stuff ()
  (maximize-frame)
  (set-foreground-color "burlywood3")
  (set-background-color "#161616")
  (set-cursor-color "#40FF40")
)
(add-hook 'window-setup-hook 'post-load-stuff t)
