(use-package denote
  :config
  (setq denote-templates
      `((memo . "* ")
        (todo . "* TODO ")))
  (setq denote-prompts
	'(title keywords template)))

(defun rostre/join-strings (strings delim)
  (mapconcat 'identity strings delim))

(defun rostre/note-history (keywords)
  ;; regex match all files matching the given keyword
  ;; and display them concatenated in a buffer
  (sort keywords 'string-lessp)
  (save-selected-window
    ;; open and clear the special buffer
    (switch-to-buffer-other-window "*rostre-note-history*")
    (erase-buffer)
    (org-mode)
    ;; add the dynamic block
    (denote-org-dblock-insert-files
     (format "__.*%s" (join-strings keywords ".*"))
     'identifier)
    ;; modify the arguments in the dblock
    (save-excursion
      (replace-string ":file-separator nil" ":file-separator t"))
    (save-excursion
      (replace-string ":reverse-sort nil" ":reverse-sort t"))
    ;; populate the dblock
    (org-dblock-update)))

(defun rostre/note-new (&optional title keywords template)
  (interactive
   (let ((args (make-vector 3 nil)))
     (dolist (prompt denote-prompts)
       (pcase prompt
         ('title (aset args 0 (denote-title-prompt
                               (when (use-region-p)
                                 (buffer-substring-no-properties
                                  (region-beginning)
                                  (region-end))))))
         ('keywords (aset args 1 (denote-keywords-prompt)))
	 ('template (aset args 2 (denote-template-prompt)))))
     (append args nil)))
  (progn
;;    (setq keywords-l (split-string keywords " "))
    (rostre/note-history keywords)
    (denote title keywords nil nil nil template)))

(defun rostre/note-new-quick (&optional template)
  (interactive
   (let ((args (make-vector 1 nil)))
     (dolist (prompt denote-prompts)
       (pcase prompt
	 ('template (aset args 0 (denote-template-prompt)))))
     (append args nil)))
  (denote "Quick note" '("inbox") nil nil nil template))
