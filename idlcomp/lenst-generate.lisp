;; loadup for mcl

(in-package :cl-user)

(defvar *base-dir*
  (make-pathname :name nil :type nil
                 :defaults
                 (or *load-pathname*
                     #+ccl (pathname (ccl:front-window)))))

(setf (logical-pathname-translations "idlcomp")
      `(("scanner;*.*" ,(merge-pathnames ":lisp-scanner:*.*" *base-dir*))
        ("**;*.*"      ,(merge-pathnames ":**:*.*" *base-dir*))
        ("*.*"         ,(merge-pathnames "*.*" *base-dir*))))

(load "idlcomp:pkgdcl")
(load "idlcomp:lisp-scanner;nfa-compiler")
(load "idlcomp:lisp-scanner;scanner-support")
(load "idlcomp:lalr-generator;lalr.lisp")
(load "idlcomp:lisp-scanner;scanner-generator")
(load "idlcomp:idl-scanner-spec")
(load "idlcomp:lalr-generator;lalr")
(load "idlcomp:idl-grammar")

(setf *lalr-debug* nil)  ; Inserts debugging code into parser if non-NIL

(with-open-stream (s (open "idlcomp:idl-scanner-parser.lisp" 
                           :direction :output
                           :if-exists :supersede))
  (print '(in-package "CLORB.IDLCOMP") s)
  (generate-to-stream  *token-list* nil s)
  (pprint '(defun def-lambda (&rest a) a) s)
  (pprint (rolands-make-parser *rules* *tokens*) s))
  
;;(load "idlcomp:idl-compiler") 
;;(compile-file "idlcomp:idl-scanner-parser.lisp")