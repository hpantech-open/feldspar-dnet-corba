;;;; clorb-struct.lisp -- CORBA Structure support

(in-package :clorb)

(defclass CORBA:struct ()
  ()) 


(defun create-struct-tc (id name members)
  (check-type id string)
  (check-type name string)
  (make-typecode :tk_struct id name
                 (coerce members 'vector)))


(defvar *specialized-structs*
  (make-hash-table :test #'equal))

(defun add-struct-class (class id)
  (assert id)
  (setf (gethash id *specialized-structs*) class))





(defgeneric type-id (struct))
(defgeneric fields (struct))


;; old:
;;#+unused-defuns
(defun struct-typecode (id name &rest fields)
  (make-typecode :tk_struct
                 id
                 (string (or name ""))
                 (coerce (loop for (name type) on fields by #'cddr
                             collect (list (string name) type))
                         'vector)))

;;;; Generic struct

(defclass generic-struct (CORBA:struct)
  ((typecode :initarg :typecode :reader generic-struct-typecode)
   (fields  :initarg :fields  :accessor fields)))

(defmethod type-id ((struct generic-struct))
  (op:id (generic-struct-typecode struct)))

(defmethod print-object ((obj CORBA:struct) stream)
  (cond (*print-readably*
         (format stream "#.(CLORB::MAKE-STRUCT ~S~:{ ~S '~S~})"
                 (type-id obj)
                 (mapcar (lambda (x) (list (car x) (cdr x)))
                         (fields obj))))

        (*print-pretty*
         (let ((fields (map 'list (lambda (pair) (list (car pair) (cdr pair)))
                            (fields obj))))
           (pprint-logical-block (stream fields
                                         :prefix "#<" :suffix ">")
             (pprint-indent :block 4)
             (typecase obj
               (generic-struct (princ (type-id obj) stream))
               (t (princ (type-of obj) stream)))
             (format stream "~{ ~_~{~W ~W~}~}" fields) )))
        (t
         (print-unreadable-object (obj stream :type t)
           (format stream "~{~S ~S~^ ~}"
                   (loop for (k . v) in (fields obj)
                         collect k collect v))))))


;; Interface:
(defun make-struct (id-or-typecode &rest nv-pairs)
  "Make a CORBA structure of type ID.
NV-PAIRS is a list field names and field values.
If ID is nil, then all fields must be supplied. Otherwise some types
of fields can be defaulted (numbers and strings)."
  (let* ((id (if (stringp id-or-typecode) 
              id-or-typecode
              (op:id id-or-typecode)))
         (class (gethash id *specialized-structs*)))
    (if class
        (apply #'make-instance class nv-pairs)
      (let* ((typecode (if (stringp id-or-typecode)
                           (get-typecode id-or-typecode)
                         id-or-typecode))
             (fields
              (multiple-value-bind (kind params)
                  (type-expand typecode)
                (assert (eq kind :tk_struct))
                (map 'list (lambda (nv)
                             (let* ((fname (lispy-name (first nv)))
                                    (val (getf nv-pairs fname nv)))
                               (cons fname
                                     (if (eq val nv)
                                         (default-from-type (second nv))
                                       val))))
                     (tcp-members params)))))
        (make-instance 'generic-struct
          :typecode typecode
          :fields fields)))))


(defun struct-in (typecode function arg)
  (let* ((params (typecode-params typecode))
         (id (tcp-id params))
         (members (tcp-members params))
         (class (gethash id *specialized-structs*)))
    (if class
      (apply #'make-instance class
             (loop for (name tc) across members
                   nconc (list (lispy-name name)
                               (funcall function tc arg))))
      (make-instance 'generic-struct
        :typecode typecode
        :fields (loop for (name tc) across members
                      collect (cons (lispy-name name)
                                    (funcall function tc arg)))))))


(defmethod struct-out ((struct CORBA:struct) typecode fn dest)
  (let* ((params (typecode-params typecode))
         (members (tcp-members params)))
    (loop for (name tc) across members
         do (funcall fn (struct-get struct name) tc dest))))

#|
(defmethod struct-out ((struct generic-struct) typecode fn dest)
  (let* ((params (typecode-params typecode))
         (members (tcp-members params)))
    (loop for (name . value) in (fields struct)
         do (funcall fn (field-typecode name members) value dest))))

(defun field-typecode (name members)
  (doseq (m members)
         (loop for (field-name tc) across members
            when (string-equal name field-name)
            return tc)))
|#




(defmethod struct-get ((struct generic-struct) (field symbol))
  (cdr (assoc field (fields struct))))

(defmethod struct-get ((struct CORBA:struct) (field string))
  (struct-get struct (lispy-name field)))


;;(defmethod typecode ((obj CORBA:struct))
;;  (get-typecode (type-id obj)))


(defun default-from-type (typecode)
  ;; FIXME: similary to arbritary-value
  (ecase (typecode-kind typecode)
    ((:tk_ushort :tk_short :tk_ulong :tk_long :tk_float :tk_double
      :tk_octet :tk_longlong :tk_ulonglong :tk_longdouble)
     0)
    ((:tk_boolean) nil)
    ((:tk_char) #\Space)
    ((:tk_string) "")
    ((:tk_sequence) nil)
    ((:tk_objref) nil)))


;;;; Specialized structs

;; Define methods for:
;; type-id, fields, struct-get


;;; clorb-struct.lisp ends here
