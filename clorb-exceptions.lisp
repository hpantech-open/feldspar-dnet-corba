;;;; Exceptions

(in-package :clorb)

;;    const unsigned long OMGVMCID = 0x4f4d0000;
(defconstant CORBA::OMGVMCID #x4f4d0000)
(defconstant min-vmcid       #x10000)

(define-enum CORBA:completion_status
  :id "IDL:omg.org/CORBA/completion_status:1.0"
  :name "completion_status"
  :members ("COMPLETED_YES" "COMPLETED_NO" "COMPLETED_MAYBE"))

(defparameter corba:tc_completion_status
  (symbol-typecode 'CORBA:completion_status))



;;;; Exception TypeCode

(define-typecode except-typecode
  :kind :tk_except
  :cdr-syntax (complex :tk_string :tk_string (sequence (:tk_string :tk_typecode)))
  :params (id name :members)
  :member-params (member_name member_type)
  :share named-typecode :shared-params 2
  :extra-slots (member-types feature-symbols))


(defun create-exception-tc (id name members)
  "Create Exception TypeCode for interface repository ID and NAME, with MEMEBERS.
Members on form: (name TypeCode)"
  (make-typecode :tk_except id name (coerce members 'vector)))



;;;; Accessors


(defgeneric exception-name (exception)
  (:documentation "The scoped symbol for the exception type"))

(defmethod any-typecode ((exception exception))
  "The typecode for the exception"
  (symbol-typecode (exception-name exception)))

(defmethod any-value ((exception exception))
  exception)

(defun exception-id (exception)
  (symbol-ifr-id (exception-name exception)))



;;;; System Exceptions

(define-condition corba:systemexception (error corba:exception)
  ((minor     :type CORBA:ULong 
              :initarg :minor      :reader system-exception-minor
              :initform 0 )
   (completed :type symbol
              :initarg :completed  :reader system-exception-completed
              :initform :completed_maybe ))
  (:report report-systemexception))

(define-method minor ((obj corba:systemexception))
  (system-exception-minor obj))

(define-method completed ((obj corba:systemexception))
  (system-exception-completed obj))

(defun report-systemexception (exc stream)
  (format stream
          "~S (~X~@[ std ~D~]) ~A."
	  (exception-name exc)
          (system-exception-minor exc)
          (if (eql omg.org/corba::omgvmcid
                   (logandc2 (system-exception-minor exc) (1- min-vmcid)))
            (logand (system-exception-minor exc) (1- min-vmcid)))
          (system-exception-completed exc)))


(defun system-exception (class &optional (minor 0) (completed :COMPLETED_MAYBE))
  (if (< minor min-vmcid)
    (setq minor (logior corba::omgvmcid minor)))
  (make-condition class :minor minor :completed completed))

(defun raise-system-exception (class &optional (minor 0) (completed :COMPLETED_MAYBE))
  (error (system-exception class minor completed)))


#+(or)
(defmethod shared-initialize :after ((obj corba:systemexception) slot-names &key)
  (declare (ignore slot-names))
  (format t "~&;;; shared-initialize ~S :minor ~X" obj (system-exception-minor obj))
)

#+(or)
(defmethod shared-initialize :after ((obj corba:systemexception) slot-names &key)
  (declare (ignore slot-names))
)



(macrolet
    ((define-system-exceptions (&rest excnames)
         `(progn
            ,@(loop for name in excnames collect
                    (let* ((namestr (string name))
                           (id (format nil "IDL:omg.org/CORBA/~A:1.0" namestr))
                           (sym (intern namestr :corba)))
                      `(progn
                         (define-condition ,sym (corba:systemexception) ())
                         (defmethod exception-name ((exc ,sym)) ',sym)
                         (set-symbol-ifr-id ',sym ,id)
                         (defun ,sym (&key (minor 0) (completed :completed_maybe))
                           (system-exception ',sym minor completed))))))))
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


#+unused-methods
(defmethod all-fields ((exc userexception))
  (map 'list
       (lambda (member) (funcall (feature (first member)) exc))
       (tc-members (any-typecode exc))))

(defun id-exception-class (id)
  (ifr-id-symbol id))


;;;; Marshalling support for exceptions

(defun exception-read (symbol buffer)
  "Read an exception of type indicated by SYMBOL from BUFFER."
  (let ((reader (get symbol 'exception-read)))
    (if reader
      (funcall reader buffer)
      (unmarshal (symbol-typecode symbol) buffer))))

(defun unmarshal-systemexception (buffer)
  (make-condition (or (ifr-id-symbol (unmarshal-string buffer))
                      'corba:systemexception)                      
                  :minor (unmarshal-ulong buffer)
                  :completed (unmarshal (symbol-typecode 'CORBA:completion_status) 
                                        buffer)))

(defmethod unmarshal ((typecode except-typecode) buffer)
  (let* ((id (op:id typecode))
         (class (id-exception-class id))
         (initargs 
          (loop for tc in (tc-member-types typecode)
                for key across (tc-keywords typecode)
                collect key
                collect (unmarshal tc buffer))))
    (if class
      (apply #'make-condition class initargs)
      (make-condition 'unknown-user-exception
                      :id id :values initargs))))


(defmethod marshal (arg (tc except-typecode) buffer)
  (marshal-string (op:id tc) buffer)
  (loop for type in (tc-member-types tc)
        for feature in (tc-feature-symbols tc)
        do (marshal (funcall feature arg) type buffer)))
