;;; idef-macros --- interface definition macros
;; $Id: idef-macros.lisp,v 1.1 2000/11/14 22:50:40 lenst Exp $

(in-package :clorb)


;;;; A Global Repository

(defvar *idef-repository*
    (make-instance 'repository))

(defun lookup-name (name)
  (lookup-name-in *idef-repository* name))

(defmethod gen-idef ((name string))
  (gen-idef (lookup-name name)))


;;;; Macro for IDEF definitions

(defmacro idef-definitions (&body forms)
  `(idef-read ',forms *idef-repository*))


;;;; Creating a servant class

(defmacro define-servant (name scoped-name &key id)
  "Creates an auto-servant class for an interface.
This class can be used almos as a skeleton class generated by an
IDL-compiler."
  `(progn
     (defclass ,name (auto-servant)
       ())
     ,@(if id 
           `((defmethod servant-interface-id ((servant ,name))
              ,id)))
     (defmethod servant-interface ((servant ,name))
       (or (ignore-errors (lookup-name ,scoped-name))
           (call-next-method)))))


(defmacro require-idl (name &key file)
  `(eval-when (:load-toplevel :execute)
     (unless (lookup-name-in *idef-repository* ,name nil)
       (load ,file))))
