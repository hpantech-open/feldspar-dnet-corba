(in-package :clorb)

(defun ir-add-all (seq &optional (level 0))
  (map nil 
    (lambda (x &aux (kind (op:def_kind x))
                    (id   (op:id x))
                    (indent (make-string level :initial-element #\. )))
      (mess 3 "-- ~A ~A - ~S - ~A" 
            indent
            (op:absolute_name x) kind id)
      (case kind
           (:dk_Module 
            (ir-add-all (op:contents x :dk_All t)
                        (1+ level)))
           (:dk_Interface
            (or (known-interface id)
                (add-interface (interface-from-def x id)))
            (ir-add-all (op:contents x :dk_All t)
                        (1+ level)))
           ((:dk_Struct :dk_Alias :dk_Exception :dk_Enum)
            ;; IDL - types
            (or (known-idl-type id)
                (add-typecode-with-id id (typecode-from-def x))))))
    seq))

(defun download-ir ()
  (ir-add-all (op:contents (get-ir) :dk_all t)))
