;;;; Exceptions

(in-package :clorb)


(defgeneric exception-name (exception)
  (:documentation "The scoped symbol for the exception type"))

(defun exception-id (exception)
  (symbol-ifr-id (exception-name exception)))


(deftype CORBA::completion_status ()
  '(member :COMPLETED_YES :COMPLETED_NO :COMPLETED_MAYBE))

(set-symbol-typecode 'CORBA:completion_status
                     (make-typecode :tk_enum
                                    "IDL:omg.org/CORBA/completion_status:1.0"
                                    "completion_status"
                                    '#("COMPLETED_YES" "COMPLETED_NO" "COMPLETED_MAYBE")))


;; Map from id to class
(defvar *system-execption-classes* 
  (make-hash-table :test #'equal))


(define-condition corba:systemexception (error corba:exception)
  ((minor :initform 0
	  :initarg :minor
	  :reader system-exception-minor)
   (completed :initform :completed_maybe
	      :initarg :completed
              :type CORBA::completion_status
	      :reader system-exception-completed))
  (:report report-systemexception))

(define-method minor ((obj systemexception))
  (system-exception-minor obj))

(define-method completed ((obj systemexception))
  (system-exception-completed obj))

(defun report-systemexception (exc stream)
  (format stream
          "Exception ~S (~A) ~A"
	  (exception-name exc)
          (system-exception-minor exc)
          (system-exception-completed exc)))


(macrolet
    ((define-system-exceptions (&rest excnames)
         `(progn
            ,@(loop for name in excnames collect
                    (let* ((namestr (string name))
                           (id (format nil "IDL:omg.org/CORBA/~A:1.0" namestr))
                           (sym (intern namestr :CORBA)))
                      `(progn
                         (define-condition ,sym (corba:systemexception) ())
                         (defmethod exception-name ((exc ,sym)) ',sym)
                         (set-symbol-ifr-id ',sym ,id)
                         (setf (gethash ,id *system-execption-classes*) ',sym) ))))))
  (define-system-exceptions
      UNKNOWN BAD_PARAM NO_MEMORY IMP_LIMIT
      COMM_FAILURE INV_OBJREF NO_PERMISSION INTERNAL MARSHAL
      INITIALIZE NO_IMPLEMENT BAD_TYPECODE BAD_OPERATION
      NO_RESOURCES NO_RESPONSE PERSIST_STORE BAD_INV_ORDER
      TRANSIENT FREE_MEM INV_IDENT INV_FLAG INTF_REPOS
      BAD_CONTEXT OBJ_ADAPTER DATA_CONVERSION OBJECT_NOT_EXIST
      TRANSACTION_REQUIRED TRANSACTION_ROLLEDBACK INVALID_TRANSACTION ))



;;;; User Exceptions
;;;
;;; exception-id exc        --> ifr-id
;;; id-exception-class id   --> exception-class
;;;


(define-condition unknown-user-exception (corba:userexception)
                  ((id :initarg :id :reader unknown-exception-id)
                   (values :initarg :values :reader unknown-exception-values)))


(defmethod any-typecode ((exception exception))
  "The typecode for the exception"
  (symbol-typecode (exception-name exception)))

(defun feature (name)
  (intern (string-upcase name) :op))

(defmethod all-fields ((exc userexception))
  (map 'list
       (lambda (member) (funcall (feature (first member)) exc))
       (tc-members (any-typecode exc))))


(defvar *user-exception-classes*
  (make-hash-table :test #'equal))

(defun id-exception-class (id)
  (gethash id *user-exception-classes*))


;;; Marshalling support for exceptions

(defun exception-read (symbol buffer)
  "Read an exception of type indicated by SYMBOL from BUFFER."
  (let ((reader (get symbol 'exception-read)))
    (if reader
      (funcall reader buffer)
      (unmarshal-exception (symbol-typecode symbol) buffer))))
