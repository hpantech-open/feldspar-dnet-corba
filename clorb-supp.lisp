;;;; clorb-supp.lisp
;; $Id: clorb-supp.lisp,v 1.2 2001/02/13 22:21:57 lenst Exp $

(in-package :clorb)

(defvar *log-output* t)

(defun mess (level fmt &rest args)
  (when (>= level *log-level*)
    (apply #'cl:format *log-output*
           (format nil "~&~A ~A~%" 
                   (make-string level :initial-element #\;)
                   fmt)
           args)))

(defun stroid (stream oid colon-p at-p)
  (declare (ignore colon-p at-p))
  (map nil
    (lambda (octet)
      (if (< 31 octet 127)
          (princ (code-char octet) stream)
        (format stream "<~x>" octet)))
    oid))


;;; clorb-supp.lisp ends here
