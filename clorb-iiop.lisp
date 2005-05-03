;;; clorb-iiop.lisp --- IIOP implementation
;; $Id: clorb-iiop.lisp,v 1.45 2005/05/03 13:25:31 lenst Exp $


(in-package :clorb)

(defconstant +iiop-header-size+ 12)


;;;; GIOP Module

(define-enum GIOP:MsgType_1_0
  :id "IDL:omg.org/GIOP/MsgType_1_0:1.0"
  :name "MsgType_1_0"
  :members ("Request" "Reply" "CancelRequest" "LocateRequest" "LocateReply" 
            "CloseConnection" "MessageError"))

(DEFINE-ENUM GIOP:MSGTYPE_1_1
  :ID "IDL:omg.org/GIOP/MsgType_1_1:1.0"
  :NAME "MsgType_1_1"
  :MEMBERS ("Request" "Reply" "CancelRequest" "LocateRequest" "LocateReply"
            "CloseConnection" "MessageError" "Fragment"))

(DEFINE-STRUCT GIOP:VERSION
  :id "IDL:omg.org/GIOP/Version:1.0"
  :name "Version"
  :members (("major" OMG.ORG/CORBA:TC_OCTET)
            ("minor" OMG.ORG/CORBA:TC_OCTET)))

(DEFINE-STRUCT GIOP:MESSAGEHEADER_1_0
  :id "IDL:omg.org/GIOP/MessageHeader_1_0:1.0"
  :name "MessageHeader_1_0"
  :members (("magic" (create-array-tc 4 OMG.ORG/CORBA:TC_CHAR))
            ("GIOP_version" (SYMBOL-TYPECODE 'GIOP:VERSION))
            ("byte_order" OMG.ORG/CORBA:TC_BOOLEAN)
            ("message_type" OMG.ORG/CORBA:TC_OCTET)
            ("message_size" OMG.ORG/CORBA:TC_ULONG)))

(DEFINE-STRUCT GIOP:MESSAGEHEADER_1_1
 :ID "IDL:omg.org/GIOP/MessageHeader_1_1:1.0"
 :NAME "MessageHeader_1_1"
 :MEMBERS (("magic" (CREATE-ARRAY-TC 4 OMG.ORG/CORBA:TC_CHAR))
           ("GIOP_version" (SYMBOL-TYPECODE 'GIOP:VERSION))
           ("flags" OMG.ORG/CORBA:TC_OCTET)
           ("message_type" OMG.ORG/CORBA:TC_OCTET)
           ("message_size" OMG.ORG/CORBA:TC_ULONG)))

(DEFINE-STRUCT GIOP:LOCATEREQUESTHEADER
 :id "IDL:omg.org/GIOP/LocateRequestHeader:1.0"
 :name "LocateRequestHeader"
 :members (("request_id" OMG.ORG/CORBA:TC_ULONG)
           ("object_key" (create-sequence-tc 0 OMG.ORG/CORBA:TC_OCTET))))

(define-enum GIOP:LocateStatusType
  :id "IDL:omg.org/GIOP/LocateStatusType:1.0"
  :name "LocateStatusType" 
  :members ("UNKNOWN_OBJECT" "OBJECT_HERE" "OBJECT_FORWARD"))

(DEFINE-STRUCT GIOP:LOCATEREPLYHEADER
 :id "IDL:omg.org/GIOP/LocateReplyHeader:1.0"
 :name "LocateReplyHeader"
 :members (("request_id" OMG.ORG/CORBA:TC_ULONG REQUEST_ID) 
           ("locate_status" (SYMBOL-TYPECODE 'GIOP:LOCATESTATUSTYPE))))

(DEFINE-STRUCT GIOP:CANCELREQUESTHEADER
 :id "IDL:omg.org/GIOP/CancelRequestHeader:1.0"
 :name "CancelRequestHeader"
 :members (("request_id" OMG.ORG/CORBA:TC_ULONG)))

(DEFINE-STRUCT GIOP:REQUESTHEADER_1_0
  :id "IDL:omg.org/GIOP/RequestHeader_1_0:1.0"
  :name "RequestHeader_1_0"
  :members (("service_context" (SYMBOL-TYPECODE 'IOP:SERVICECONTEXTLIST))
            ("request_id" OMG.ORG/CORBA:TC_ULONG)
            ("response_expected" OMG.ORG/CORBA:TC_BOOLEAN)
            ("object_key" (create-sequence-tc 0 OMG.ORG/CORBA:TC_OCTET))
            ("operation" OMG.ORG/CORBA:TC_STRING)
            ("requesting_principal" (SYMBOL-TYPECODE 'GIOP:PRINCIPAL))))

(DEFINE-STRUCT GIOP:REQUESTHEADER_1_1
  :ID "IDL:omg.org/GIOP/RequestHeader_1_1:1.0"
  :NAME "RequestHeader_1_1"
  :MEMBERS (("service_context"
             (SYMBOL-TYPECODE 'OMG.ORG/IOP:SERVICECONTEXTLIST))
            ("request_id" OMG.ORG/CORBA:TC_ULONG)
            ("response_expected" OMG.ORG/CORBA:TC_BOOLEAN)
            ("reserved" (CREATE-ARRAY-TC 3 OMG.ORG/CORBA:TC_OCTET))
            ("object_key" (CREATE-SEQUENCE-TC 0 OMG.ORG/CORBA:TC_OCTET))
            ("operation" OMG.ORG/CORBA:TC_STRING)
            ("requesting_principal" (SYMBOL-TYPECODE 'OMG.ORG/GIOP:PRINCIPAL))))

(define-enum GIOP:REPLYSTATUSTYPE 
  :id "IDL:omg.org/GIOP/ReplyStatusType:1.0"
  :name "ReplyStatusType"
  :members ("NO_EXCEPTION" "USER_EXCEPTION" "SYSTEM_EXCEPTION"
                           "LOCATION_FORWARD"))

(DEFINE-STRUCT GIOP:REPLYHEADER
  :id "IDL:omg.org/GIOP/ReplyHeader:1.0"
  :name "ReplyHeader"
  :members (("service_context" (SYMBOL-TYPECODE 'IOP:SERVICECONTEXTLIST))
            ("request_id" OMG.ORG/CORBA:TC_ULONG)
            ("reply_status" (SYMBOL-TYPECODE 'GIOP:REPLYSTATUSTYPE))))

(define-alias GIOP:Principal
  :id "IDL:omg.org/GIOP/Principal:1.0"
  :name"Principal" 
  :type sequence
  :typecode (create-sequence-tc 0 OMG.ORG/CORBA:TC_OCTET))



;;;; GIOP (un)marshal extras

(defun marshal-giop-set-message-length (buffer)
  (with-out-buffer (buffer)
    (let ((len pos))
      (setf pos 8)
      (marshal-ulong (- len 12) buffer)
      (setf pos len))))


(defun marshal-service-context (ctx buffer)
  (marshal-sequence ctx 
                    (lambda (service-context buffer)
                      (marshal-ulong (op:context_id service-context) buffer)
                      (marshal-osequence (op:context_data service-context) buffer))
                    buffer))

(defun unmarshal-service-context (buffer)
  (unmarshal-sequence-m (buffer) 
    (IOP:ServiceContext :context_id (unmarshal-ulong buffer)
	                :context_data (unmarshal-osequence buffer))))


;;;; IIOP Module


(DEFINE-STRUCT IIOP:VERSION
  :ID "IDL:omg.org/IIOP/Version:1.0"
  :NAME "Version"
  :MEMBERS (("major" OMG.ORG/CORBA:TC_OCTET) 
            ("minor" OMG.ORG/CORBA:TC_OCTET)))

(DEFINE-STRUCT IIOP:PROFILEBODY_1_0
  :ID "IDL:omg.org/IIOP/ProfileBody_1_0:1.0"
  :NAME "ProfileBody_1_0"
  :MEMBERS (("iiop_version" (SYMBOL-TYPECODE 'IIOP:VERSION)) 
            ("host" OMG.ORG/CORBA:TC_STRING)
            ("port" OMG.ORG/CORBA:TC_USHORT)
            ("object_key" (CREATE-SEQUENCE-TC 0 OMG.ORG/CORBA:TC_OCTET))))

(DEFINE-STRUCT IIOP:PROFILEBODY_1_1
  :ID "IDL:omg.org/IIOP/ProfileBody_1_1:1.0"
  :NAME "ProfileBody_1_1"
  :MEMBERS (("iiop_version" (SYMBOL-TYPECODE 'IIOP:VERSION))
            ("host" OMG.ORG/CORBA:TC_STRING)
            ("port" OMG.ORG/CORBA:TC_USHORT)
            ("object_key" (CREATE-SEQUENCE-TC 0 OMG.ORG/CORBA:TC_OCTET))
            ("components" (CREATE-SEQUENCE-TC 0 (SYMBOL-TYPECODE 'OMG.ORG/IOP:TAGGEDCOMPONENT)))))


;;;; Version

(defun make-iiop-version (major minor)
  (or (if (eql major 1)
        (case minor 
          (0 '(1 . 0))  (1 '(1 . 1)) (2 '(1 . 2))))
      :iiop_unknown_version))

(defun iiop-version-major (version) (car version))
(defun iiop-version-minor (version) (cdr version))


(defun make-giop-version (major minor)
  (or (if (eql major 1)
        (case minor 
          (0 :giop_1_0) (1 :giop_1_1) (2 :giop_1_2)))
      :giop_unknown_version))
  
(defun giop-version-major (version)
  (if (eql version :giop_unknown_version)
      (error "Unknown version")
      1))
(defun giop-version-minor (version)
  (case version (:giop_1_0 0) (:giop_1_1 1) (:giop_1_2 2) (otherwise 9999)))

(defconstant giop-1-0 :giop_1_0)
(defconstant giop-1-1 :giop_1_1)


;;;; IIOP - Profiles


(defstruct IIOP-PROFILE
  (version (make-iiop-version 1 0))
  (host    nil)
  (port    0    :type fixnum)
  (key     nil)
  (components nil))


(defmethod profile-short-desc ((profile IIOP-PROFILE) stream)
  (format stream "~A@~A:~A" 
          (iiop-profile-version profile)
          (iiop-profile-host profile)
          (iiop-profile-port profile)))

(defmethod profile-equal ((profile1 iiop-profile) (profile2 iiop-profile))
  (and (equal (iiop-profile-host profile1) (iiop-profile-host profile2))
       (equal (iiop-profile-port profile1) (iiop-profile-port profile2))
       (equalp (iiop-profile-key profile1) (iiop-profile-key profile2))))

(defmethod profile-hash ((profile iiop-profile))
  (sxhash (list* (iiop-profile-host profile)
                 (iiop-profile-port profile)
                 (coerce (iiop-profile-key profile) 'list))))

(defmethod profile-component ((profile iiop-profile) tag)
  (cdr (assoc tag (iiop-profile-components profile))))

(defmethod decode-ior-profile ((tag (eql 0)) encaps)
  (unmarshal-encapsulation encaps #'unmarshal-iiop-profile-body))


(defun unmarshal-iiop-componets (buffer)
  ;; Try handle profiles without components such as IIOP 1.0, 
  ;; this shouldn't realy be called for those but any way
  (let ((len (if (< (buffer-in-pos buffer) (buffer-length buffer))
               (unmarshal-ulong buffer)
               0)))
    (loop repeat len collect 
          (let ((tag (unmarshal-ulong buffer)))
            (cond ((= tag IOP:TAG_ORB_TYPE)
                   (cons tag (with-encapsulation buffer (unmarshal-ulong buffer))))
                  (t 
                   (cons tag (unmarshal-osequence buffer))))))))


(defun marshal-iiop-components (components buffer)
  (marshal-ulong (length components) buffer)
  (loop for (tag . component) in components do
        (marshal-ulong tag buffer)
        (cond ((= tag IOP:TAG_ORB_TYPE) 
               (marshal-add-encapsulation
                (lambda (buffer) (marshal-ulong component buffer))
                buffer))
              (t
               (marshal-add-encapsulation
                (lambda (buffer) (marshal-osequence component buffer))
                buffer)))))


(defun unmarshal-iiop-profile-body (buffer)
  (let ((major (unmarshal-octet buffer))
        (minor (unmarshal-octet buffer)))
    (make-iiop-profile
     :version (make-iiop-version major minor)
     :host (unmarshal-string buffer)
     :port (unmarshal-ushort buffer)
     :key (unmarshal-osequence buffer)
     :components (if (> minor 0)
                   (unmarshal-iiop-componets buffer)))))



(defmethod raw-profiles ((objref CORBA:Proxy))
  (or (object-raw-profiles objref)
      (setf (object-raw-profiles objref)
            (map 'list
                 (lambda (p)
                   (cons iop:tag_internet_iop
                         (marshal-make-encapsulation
                          (lambda (buffer)
                            (let ((version (iiop-profile-version p)))
                              (marshal-octet (iiop-version-major version) buffer)
                              (marshal-octet (iiop-version-minor version) buffer)
                              (marshal-string (iiop-profile-host p) buffer)
                              (marshal-ushort (iiop-profile-port p) buffer)
                              (marshal-osequence (iiop-profile-key p) buffer)
                              (if (> (iiop-version-minor version) 0)
                                (marshal-iiop-components 
                                 (iiop-profile-components p)
                                 buffer))))
                          (the-orb objref))))
                 (object-profiles objref)))))




;;;; IIOP - Connection request preparation


(defun connection-start-locate-request (conn req-id profile)
  (let ((buffer (get-work-buffer (the-orb conn))))
    (marshal-giop-header :locaterequest buffer)
    (marshal-ulong req-id buffer)
    (marshal-osequence (iiop-profile-key profile) buffer)
    buffer))


(defun connection-start-request (conn req-id service-context response-expected
                                          effective-profile operation)
  (let ((buffer (get-work-buffer (the-orb conn))))
    (marshal-giop-header :request buffer 
                         (if (> (iiop-version-minor (iiop-profile-version effective-profile))
                                0)
                           giop-1-1 giop-1-0))
    (marshal-service-context service-context buffer)
    (marshal-ulong req-id buffer)
    (marshal-octet (if response-expected 1 0) buffer)
    (marshal-osequence 
     (iiop-profile-key effective-profile)
     buffer)
    (marshal-string operation buffer)
    (marshal-osequence *principal* buffer)
    buffer))


(defun connection-send-request (conn buffer req)
  (marshal-giop-set-message-length buffer)
  (connection-send-buffer conn buffer)
  (when req
    (connection-add-client-request conn req)))


;;;; Connection Reply Handling

(defun connection-reply (conn giop-version reply-type request-id status
                                 service-context result-func result-arg)
  (let* ((orb (the-orb conn))
         (buffer (get-work-buffer orb)))
    (setf (buffer-giop-version buffer) giop-version)
    (marshal-giop-header reply-type buffer giop-version)
    (ecase reply-type
      (:reply
       (marshal-service-context service-context buffer) 
       (marshal-ulong request-id buffer)
       (%jit-marshal status (symbol-typecode 'GIOP:REPLYSTATUSTYPE) buffer))
      (:locatereply
       (marshal-ulong request-id buffer)
       (marshal-ulong (ecase status
                        (:unknown_object 0)
                        (:object_here 1)
                        (:location_forward 2))
                      buffer)))
    (when result-func (funcall result-func result-arg buffer))
    (mess 3 "#~D send ~S ~S" request-id reply-type status)
    (marshal-giop-set-message-length buffer)
    (connection-send-buffer conn buffer)))


(defun server-close-connection (conn)
  ;; Do a server side close connection
  (unless (connection-write-buffer conn)
    ;; No pending send, send a close connection message
    (let* ((orb (the-orb conn))
           (buffer (get-work-buffer orb)))
      (marshal-giop-header :closeconnection buffer)
      (marshal-giop-set-message-length buffer)
      (connection-send-buffer conn buffer))
    (connection-destroy conn)))

(defun connection-message-error (conn &optional (version giop-1-0))
  (let* ((orb (the-orb conn))
         (buffer (get-work-buffer orb)))
    (marshal-giop-header :messageerror buffer version)
    (marshal-giop-set-message-length buffer)
    (connection-send-buffer conn buffer))
  (connection-error conn)
  (connection-destroy conn))


;;;; IIOP - Response handling

(define-symbol-macro message-types
  '#(:REQUEST :REPLY :CANCELREQUEST :LOCATEREQUEST :LOCATEREPLY
              :CLOSECONNECTION :MESSAGEERROR :FRAGMENT))


(defun unmarshal-giop-header (buffer)
  (with-in-buffer (buffer)
    (if (loop for c in '#.(mapcar #'char-code '(#\G #\I #\O #\P))
		  always (eql c (get-octet)))
      (let ((major (get-octet))
            (minor (get-octet))
            (flags (get-octet))
            (msgtype (get-octet)))
        (setf (buffer-byte-order buffer) (logand flags 1))
        (values (if (> msgtype (length message-types))
                  :unknown
                  (aref message-types msgtype))
                (if (> minor 0)
                  (logbitp 1 flags))
                (make-giop-version major minor)))
      (progn (warn "Not a GIOP message: ~/net.cddr.clorb::stroid/" octets)
             (values :unknown)))))


(defun marshal-giop-header (type buffer &optional (version giop-1-0) fragmented)
  (with-out-buffer (buffer)
    #.(cons 'progn (loop for c across "GIOP" collect `(put-octet ,(char-code c))))
    (put-octet (giop-version-major version))
    (put-octet (giop-version-minor version))
    (put-octet (logior 1 		;byte-order
                       (if fragmented 2 0)))
    (put-octet (cond ((numberp type) type)
                     ((eq type 'request) 0)
                     ((eq type 'reply) 1)
                     (t 
                      (let ((n (position type message-types)))
                        (or n (error "Message type ~S" type))))))
    ;; Place for message length to be patched in later
    (incf pos 4)))


(defun get-fragment (conn)
  (let ((buffer (connection-read-buffer conn)))
    (connection-add-fragment conn buffer +iiop-header-size+)
    (setup-outgoing-connection conn)))

(defun get-fragment-last (conn)
  (let ((buffer (connection-read-buffer conn)))
    (connection-add-fragment conn buffer +iiop-header-size+)
    (let ((handler (assembled-handler conn)))
      (setf (assembled-handler conn) nil)
      (setf (fragment-buffer conn) nil)
      (funcall handler conn))))


(defun get-response-0 (conn)
  (let ((buffer (connection-read-buffer conn)))
    (multiple-value-bind (msgtype fragmented)
        (unmarshal-giop-header buffer)
      (let ((size (+ (unmarshal-ulong buffer) +iiop-header-size+))
            (handler
             (ecase msgtype
               ((:reply) #'get-response-reply)
               ((:locatereply) #'get-response-locate-reply)
               ((:closeconnection)
                (mess 3 "Connection closed")
                (connection-close conn)
                nil)
               ((:messageerror)
                (mess 6 "CORBA: Message error")
                (connection-error conn)
                (connection-destroy conn)
                nil)
               ((:fragment)
                (prog1 
                    (if fragmented #'get-fragment #'get-fragment-last)
                  (setf fragmented nil))))))
        (when fragmented
          (connection-init-defragmentation conn handler)
          (setq handler #'get-fragment))
        (if handler
            (connection-init-read conn t size handler)
            ;; prehaps it is better to close it....
            (setup-outgoing-connection conn))))))


(defun get-response-reply (conn)
  (let* ((buffer (connection-read-buffer conn))
         (service-context (unmarshal-service-context buffer))
         (request-id (let ((id (unmarshal-ulong buffer)))
                       ;;(break "id=~d" id)
                       id ))
         (req (find-waiting-client-request conn request-id))
         (status (%jit-unmarshal (symbol-typecode 'GIOP:ReplyStatusType) buffer)))
    (setup-outgoing-connection conn)
    (when req
      (request-reply req status buffer service-context))))


(defun get-response-locate-reply (conn &aux (buffer (connection-read-buffer conn)))
  (setup-outgoing-connection conn)
  (let* ((request-id (unmarshal-ulong buffer))
         (status (%jit-unmarshal (symbol-typecode 'giop:locatestatustype) buffer))
         (req (find-waiting-client-request conn request-id)))
    (when req
      (request-locate-reply req status buffer))))



;;;; IIOP - Manage outgoing connections

(defvar *iiop-connections* nil
  "All active client sockets.
Organized as two levels of a-lists:
  ( (host . ((port . socket) ...)) ...)
Where host is a string and port an integer.")


(defun setup-outgoing-connection (conn)
  (connection-init-read conn nil +iiop-header-size+ #'get-response-0))


(defun get-iiop-connection-holder (host port)
  ;; a cons cell where cdr is for connection
  (let* ((host-list				; A host-ports pair
	  (assoc host *iiop-connections* :test #'equal))
	 (holder				; A port-socket pair
	  (assoc port (cdr host-list))))
    (unless holder
      (unless host-list
        (setq host-list (cons host nil))
	(push host-list *iiop-connections*))
      (setq holder (cons port nil))
      (push holder (cdr host-list)))
    holder))


(defun get-iiop-connection (orb host port)
  (let* ((holder (get-iiop-connection-holder host port))
         (conn   (cdr holder)))
    (unless (and conn (connection-working-p conn))
      (when conn (connection-destroy conn))
      (setq conn (create-connection orb host port))
      (when conn (setup-outgoing-connection conn))
      (setf (cdr holder) conn))
    conn))

(defmethod profile-connection ((profile iiop-profile) orb)
  (let ((host (iiop-profile-host profile))
        (port (iiop-profile-port profile)))
    (get-iiop-connection orb host port)))

(defmethod profile-connection ((profile vector) orb)
  ;; Multi profile
  ;; FIXME: not handled yet, should it be stored in the proxy ??
  nil)


;;;; Locate

(defun locate (obj)
  (let ((req (create-client-request (the-orb obj)
                                    :target obj :operation 'locate)))
    (loop
      (multiple-value-bind (conn req-id)
                           (request-start-request req)
        (let ((buffer (connection-start-locate-request conn req-id
                                                       (request-effective-profile req))))
          (connection-send-request conn buffer req)))
      (request-wait-response req)
      (cond ((eql (request-status req) :object_forward)
             (setf (object-forward obj) (unmarshal-object (request-buffer req))))
            (t 
             (return (request-status req)))))))


;;;; Attribute accessors

(defun get-attribute (obj getter result-tc)
  (static-call (getter obj)
               :output ((buffer))
               :input ((buffer) (unmarshal result-tc buffer))))

(defun set-attribute (obj setter result-tc newval)
  (static-call (setter obj)
               :output ((buffer) (marshal newval result-tc buffer))
               :input ((buffer))))

