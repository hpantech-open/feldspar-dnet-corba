;;;; clorb-poa.lisp -- Portable Object Adaptor
;; $Id: clorb-poa.lisp,v 1.2 2001/06/03 20:48:56 lenst Exp $

(in-package :clorb)


;;;; Servant manager

(defclass ServantManager () ())

;;  interface ServantActivator : ServantManager {

(defclass ServantActivator (ServantManager) ())

;; Servant incarnate (in ObjectId oid, in POA adapter)
;;    raises (ForwardRequest);

(define-method incarnate ((s ServantActivator) oid adapter)
  ;; Raises ForwardRequest
  (declare (ignore oid adapter))
  nil)

(define-method etherealize ((s ServantActivator)
                            oid adapter servant cleanup-in-progress
                            reamining-activations)
  (declare (ignore oid adapter servant cleanup-in-progress 
                      reamining-activations))
  nil)

(defclass ServantLocator (ServantManager) ())

(deftype ServantLocator/cookie () t)

(define-method preinvoke ((s ServantManager) oid adapter operation)
  (declare (ignore oid adapter operation cookie))
  ;; result Servant, out cookie
  (values nil nil))

(define-method postinvoke ((s ServantManager)
                          oid adapter operation cookie servant)
  (declare (ignore oid adapter operation cookie servant))
  nil)



;;; Class: POA

(define-corba-class POA ()
  :attributes ((the_name :readonly)
               (the_parent :readonly) 
               (the_POAManager :readonly) 
               (the_activator))
  :slots ((active-servant-map 
           :initform (make-hash-table)
           :reader poa-active-servant-map
           :documentation "servant->id")
          (active-object-map 
           :initform (make-trie)
           :reader poa-active-object-map
           :documentation "id->servant")
          (servant-manager :accessor poa-servant-manager)
          (default-servant :accessor poa-default-servant)
          (policies :initarg :policies :accessor poa-policies)
          (poaid :initarg :poaid :accessor poa-poaid)
          (auto-id :accessor poa-auto-id :initform 0)
          (children :initform nil :accessor poa-children)
          (the-orb :accessor the-orb)))

(defmethod print-object ((p POA) stream)
  (print-unreadable-object (p stream :type t)
    (format stream "~A ~D objects"
            (op:the_name p)
            (dict-count (POA-active-object-map p)))))

(defun poa-name (poa)
  (labels ((name-list (poa parent)
             (if (null parent)
                 nil
               (cons (op:the_name poa) 
                     (name-list parent (op:the_parent parent))))))
    (nreverse (name-list poa (op:the_parent poa)))))

;;;; Exceptions

(define-user-exception ForwardRequest 
    :id "IDL:omg.org/PortableServer/ForwardRequest:1.0"
    :slots ((forward_reference
             :initarg :forward_reference)))

(define-user-exception POA/AdapterNonExistent 
    :id "IDL:omg.org/PortableServer/POA/AdapterNonExistent:1.0")

(define-user-exception POA/WrongPolicy
    :id "IDL:omg.org/PortableServer/POA/WrongPolicy:1.0")

(define-user-exception POA/ObjectNotActive
    :id "IDL:omg.org/PortableServer/POA/ObjectNotActive:1.0")

(define-user-exception POA/WrongAdapter
    :id "IDL:omg.org/PortableServer/POA/WrongAdapter:1.0"
    :slots ((types :initform nil)))

(define-user-exception POA/AdapterAlreadyExists
    :id "IDL:omg.org/PortableServer/POA/AdapterAlreadyExists:1.0")

(define-user-exception POA/AdapterInactive
    :id "IDL:omg.org/PortableServer/POA/AdapterInactive:1.0")

(define-user-exception POA/InvalidPolicy
    :id "IDL:omg.org/PortableServer/POA/InvalidPolicy:1.0"
    :slots ((index)))

(define-user-exception POA/NoServant
    :id "IDL:omg.org/PortableServer/POA/NoServant:1.0")

(define-user-exception POA/ObjectAlreadyActive
    :id "IDL:omg.org/PortableServer/POA/ObjectAlreadyActive:1.0")

(define-user-exception POA/ServantAlreadyActive
    :id "IDL:omg.org/PortableServer/POA/ServantAlreadyActive:1.0")

(define-user-exception POA/ServantNotActive
    :id "IDL:omg.org/PortableServer/POA/ServantNotActive:1.0")


;;;; Struct poa-current

(defvar *poa-current* nil
  "The PortableServer::Current object for the current invocation.")

(defstruct poa-current 
  POA
  object-id)


;;;; POA Registry

(defvar *root-POA* nil)

(defvar *last-poaid* 0)

(defvar *poa-map*
  #+cmu (make-hash-table :test #'eql  :weak-p t)
  #+allegro (make-hash-table :test #'eql  :values :weak)
  #-(or cmu allegro) (make-hash-table :test #'eql ))

(defun register-poa (poa)
  (setf (gethash (poa-poaid poa) *poa-map*) poa))

(defun unregister-poa (poa)
  (remhash (poa-poaid poa) *poa-map*))

(defun decode-object-key-poa (objkey)
  (multiple-value-bind (type poaid oid)
      (decode-object-key objkey)
    (let (poa)
      (if (numberp poaid)
          (setq poa (gethash poaid *poa-map*))
          (progn
            (setq poa *root-POA*)
            (handler-case
                (loop for n in poaid
                      do (setq poa (op:find_poa poa n t)))
              (POA/AdapterNonExistent ()
               (setq poa nil)))))
      (values type poa oid))))


;;;; Create, find and destroy 

(defun create-POA (poa name manager policies)
  (let ((policy-groups
         '((:retain :non-retain)
           (:transient :persistent)
           (:system-id :user-id)
           (:unique-id :multiple-id)
           (:use-active-object-map-only :use-default-servant
            :use-servant-manager)
           (:implicit-activation :no-implicit-activation))))
    (loop for p in policies
        for i from 0
        for g = (find p policy-groups :test #'member)
        do (cond (g (setq policy-groups (remove g policy-groups)))
                 (t (error 'InvalidPolicy :index i))))
    (loop for g in policy-groups
        do (push (car g) policies)))
  (let ((newpoa
         (make-instance 'POA
          :the_name name
          :the_parent poa
          :the_POAmanager (or manager (make-instance 'POAManager))
          :policies policies
          :poaid (incf *last-poaid*))))
    (when poa
      (push newpoa (POA-children poa))
      (setf (the-orb newpoa) (the-orb poa)))
    (register-poa newpoa)
    newpoa))

(define-method create_POA ((poa POA) adapter-name poamanager policies)
  (create-POA poa adapter-name poamanager policies))

(define-method find_POA ((poa POA) name &optional activate-it)
  (or (find name (POA-children poa)
            :key #'op:the_name :test #'equal)
      (cond ((and activate-it (op:the_activator poa))
             (funcall (op:the_activator poa) poa name)
             (find name (POA-children poa)
                   :key #'op:the_name :test #'equal)))
      (error 'POA/AdapterNonExistent)))

;;     void destroy(	in boolean etherealize_objects,
;;  		        in boolean wait_for_completion);

(define-method destroy ((poa POA) etherealize-objects wait-for-completion)
  (declare (ignore wait-for-completion))
  ;; FIXME: what about the children?
  (let ((parent (op:the_parent poa)))
    (setf (POA-children parent)
          (delete poa (POA-children parent))))
  (unregister-poa poa)
  (when (and etherealize-objects
             (member :retain (POA-policies poa))
             (member :use-servant-manager (POA-policies poa)))
    (maptrie (lambda (oid servant)
               (op:etherealize
                (POA-servant-manager poa) 
                oid poa servant t nil))
             (POA-active-object-map poa))))


;;;; some setters and getters

(defun check-policy (poa policy)
  (unless (member policy (POA-policies poa))
    (error 'POA/WrongPolicy)))

;;;  ServantManager get_servant_manager()
;;;    raises (WrongPolicy);

(define-method get_servant_manager ((poa POA))
  (check-policy poa :use-servant-manager)
  (poa-servant-manager poa))

;;;  void set_servant_manager( in ServantManager imgr)
;;;    raises (WrongPolicy);

(define-method set_servant_manager ((poa POA) imgr)
  (check-policy poa :use-servant-manager)
  (setf (poa-servant-manager poa) imgr))

;;;  Servant get_servant()
;;;    raises (NoServant, WrongPolicy);

(define-method get_servant ((poa POA))
  (check-policy poa :use-default-servant)
  (poa-default-servant poa))

;;;  void set_servant(	in Servant p_servant)
;;;    raises (WrongPolicy);

(define-method set_servant ((poa POA) servant)
  (check-policy poa :use-default-servant)
  (setf (poa-default-servant poa) servant))


;; ------------------------------------------------------------------
;;;; Object Activation and Deactivation
;; ------------------------------------------------------------------

(defun generate-id (poa)
  (check-policy poa :system-id)
  (if (member :persistent (POA-policies poa))
      (to-object-id (princ-to-string (get-internal-real-time))) 
    (to-object-id (incf (POA-auto-id poa)))))

(define-method activate_object ((poa POA) servant)
  (op:activate_object_with_id poa (generate-id poa) servant))

(define-method activate_object_with_id ((poa POA) id servant)
  (check-policy poa :retain)
  (setq id (to-object-id id))
  (trie-set id (POA-active-object-map poa) servant)
  (setf (gethash servant (POA-active-servant-map poa)) id))

(define-method deactivate_object ((poa POA) oid)
  (check-policy poa :retain)
  (setq oid (to-object-id oid))
  (let ((servant (trie-get oid (POA-active-object-map poa))))
    (trie-remove oid (POA-active-object-map poa))
    ;; FIXME: what about multiple-id policy
    (remhash servant (POA-active-servant-map poa))
    (when (member :use-servant-manager (POA-policies poa))
      (op:etherealize (POA-servant-manager poa) 
                       oid poa servant nil nil))))


;; ----------------------------------------------------------------------
;;;; Reference creation operations
;; ----------------------------------------------------------------------

(define-method create_reference ((poa POA) intf)
  (op:create_reference_with_id poa (generate-id poa) intf))

(define-method create_reference_with_id ((poa POA) oid intf)
  (make-instance (find-proxy-class intf)
   :id intf
   :key (make-object-key (if (member :persistent (POA-policies poa))
                             :persistent
                           :transient)
                         (poa-poaid poa) oid
                         :poa-name (poa-name poa))
   :host (or *host* (orb-host (the-orb poa)))
   :port (orb-port (the-orb poa))))

(defun object-key-id (object-key)
  (map 'string #'code-char
       (subseq object-key (1+ (position 0 object-key :from-end t)))))


;; ----------------------------------------------------------------------
;;;; Identity Mapping Operations
;; ----------------------------------------------------------------------

;;;   ObjectId servant_to_id(in Servant p_servant)
;;;     raises (ServantNotActive, WrongPolicy);

(define-method servant_to_id ((poa POA) servant)
  (multiple-value-bind (id flag)
      (gethash servant (POA-active-servant-map poa))
    (if flag
	id
	(let ((id (generate-id poa)))
	  (op:activate_object_with_id poa id servant)
	  id))))

;;;   Object servant_to_reference(in Servant p_servant)
;;;     raises (ServantNotActive, WrongPolicy);

(define-method servant_to_reference ((poa POA) servant)
  (op:create_reference poa (op:servant_to_id poa servant)))

;;;   Servant reference_to_servant(in Object reference)
;;;     raises (ObjectNotActive, WrongAdapter, WrongPolicy);

(define-method reference_to_servant ((poa POA) reference)
  (op:id_to_servant poa (op:reference_to_id poa reference)))

;;;   ObjectId reference_to_id(in Object reference)
;;;     raises (WrongAdapter, WrongPolicy);

(define-method reference_to_id ((poa POA) reference)
  (multiple-value-bind (ref-type refpoa oid)
      (decode-object-key-poa (object-key reference))
    (declare (ignore ref-type))
    (unless (eql refpoa poa)
      (error 'POA/WrongAdapter))
    oid))

;;;   Servant id_to_servant(in ObjectId oid)
;;;     raises (ObjectNotActive, WrongPolicy);

(define-method id_to_servant ((poa POA) id)
  (or (trie-get (to-object-id id) (POA-active-object-map poa))
      (error 'POA/ObjectNotActive)))

;;;   Object id_to_reference(in ObjectId oid)
;;;     raises (ObjectNotActive, WrongPolicy);

(define-method id_to_reference ((poa POA) oid)
  (op:servant_to_reference poa
                            (op:id_to_servant poa oid)))

;; ----------------------------------------------------------------------
;;;; Request Handling
;; ----------------------------------------------------------------------

(defun poa-invoke (poa sreq)
  (handler-case    
      (progn
        (unless (eq :active (op:get_state (op:the_poamanager poa)))
          (error 'CORBA:TRANSIENT :completed :completed_no))
        (poa-invoke-1 poa sreq))

    (ForwardRequest (fwd)
      (mess 4 "forwarding")
      (set-request-forward sreq (car (userexception-values fwd))))
    (exception (exc)
      (set-request-exception sreq exc))
    #+ignore
    (error ()
      (set-request-exception sreq (make-condition 'CORBA:UNKNOWN))))
  (send-response sreq))

(defun poa-invoke-1 (poa sreq)
  (let* ((oid (server-request-oid sreq))
         (operation (server-request-operation sreq))
         (*poa-current*
          (make-poa-current :POA poa :object-id oid))
         (servant (trie-get oid (POA-active-object-map poa)))
         (cookie nil)
         (topost nil))
    (cond (servant)
          ((member :use-servant-manager (POA-policies poa))
           (cond ((member :retain (POA-policies poa))
                  (setq servant
                    (op:incarnate (POA-servant-manager poa) oid poa))
                  (op:activate_object_with_id poa oid servant))
                 (t
                  (multiple-value-setq (servant cookie)
                    (op:preinvoke (POA-servant-manager poa)
                                   oid poa operation))
                  (setq topost t))))
          ((member :use-default-servant (POA-policies poa))
           (setq servant (POA-default-servant poa)))
          (t
           (error 'CORBA:OBJECT_NOT_EXIST
                  :completed :completed_no)))
    (setf (server-request-servant sreq) servant)
    (unwind-protect
        (cond ((eq operation 'locate)
               (set-request-result sreq nil nil :status 1))
              (t
               (servant-invoke servant sreq)))
      (when topost
        (op:postinvoke (POA-servant-manager poa)
                        oid poa operation cookie servant)))))


;;;; PortableServer::Current

(defclass PortableServer::Current ()
  ;;FIXME: should sublcass CORBA:Current
  ())

(define-user-exception Current/NoContext
    :id "IDL:omg.org/PortableServer/Current/NoContext:1.0")

(define-method get_POA ((current PortableServer::Current))
  (unless *poa-current* (error 'Current/NoContext))
  (poa-current-POA *poa-current*))

(define-method get_object_id ((current PortableServer::Current))
  (unless *poa-current* (error 'Current/NoContext))
  (poa-current-object-id *poa-current*))

(eval-when (:load-toplevel :execute)
  (pushnew (cons "POACurrent" 
                 (lambda (orb)
                   (declare (ignore orb))
                   (make-instance 'PortableServer::Current)))
           *default-initial-references*
           :key #'car :test #'equal ))

;;; clorb-poa.lisp ends here
