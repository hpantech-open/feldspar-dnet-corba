(in-package :clorb)

;;; TCP/IP sockets implementation glue

;;; Frob with the *features* to make this all a bit easier.

;;; The :sockets (db-sockets) library can be used in CMUCL or SBCL:
;;; it's optional (though desirable) in the former, which otherwise
;;; uses its usual socket support (cmucl-sockets).  In SBCL we have
;;; no other option

#+(or cmu sbcl)
(eval-when (:compile-toplevel :load-toplevel)
  (if (find-package "SOCKETS")
      (pushnew :db-sockets *features*)
    #+cmu (pushnew :cmucl-sockets *features*)
    #+sbcl (error "We need the SOCKETS library; SBCL doesn't have its own")))


(defmacro %SYSDEP (desc &rest forms)
  (when (zerop (length forms))
      (error "No system dependent code to ~A" desc))
  (car forms))


;; the unconnected socket is returned by OPEN-PASSIVE-SOCKET and used
;; in ACCEPT-CONNECTION-ON-PORT and COERCE-TO-WAITABLE-THING

;;; In Acl this is some type internal to the socket packet, I rather not
;; put in a dependency on that.                    [lenst/2000-05-18 21:07:21]
;(deftype unconnected-socket ()
;  #+allegro 'integer                    ;this is a complete guess
;  #+clisp 'socket-server                ;I checked this one
;  #+db-sockets 'sockets:inet-socket
;  #+cmucl-sockets 'integer
;  )

;; connected sockets must be streams

(defun open-passive-socket (port)
  "Returns an UNCONNECTED-SOCKET for a TCP socket listening on PORT.  Set SO_REUSEADDDR if possible"
  (%SYSDEP
   "open listner socket"
   #+clisp 
   (lisp:socket-server port)
   #+cmucl-sockets 
   (ext:create-inet-listener port)
   #+db-sockets
   (let ((s (sockets:make-inet-socket :stream :tcp)))
     (setf (sockets:sockopt-reuse-address s) t)
     (sockets:socket-bind s #(0 0 0 0) port)
     (sockets:socket-listen s 5)
     s)
   #+allegro
   (socket:make-socket :connect :passive :local-port port
                       :format :binary
                       :reuse-address t)))

(defun open-active-socket (host port)
  "Open a TCP connection to HOST:PORT, and return the stream asociated with it"
  (%SYSDEP
   "open socket to host/port"
   #+clisp 
   (socket-connect port host :element-type '(unsigned-byte 8))
   #+cmucl-sockets
   (system:make-fd-stream (ext:connect-to-inet-socket host port)
                          :input t :output t :element-type
                          '(unsigned-byte 8))
   #+db-sockets
   (let ((s (sockets:make-inet-socket :stream :tcp))
         (num (car (sockets:host-ent-addresses
                    (sockets:get-host-by-name host)))))
     (sockets:socket-connect s num port)
     (sockets:socket-make-stream s :element-type '(unsigned-byte 8)
                                 :input t :output t :buffering :none))
   #+allegro
   (socket:make-socket 
    :remote-host host :remote-port port
    :format :binary)))


(defun accept-connection-on-socket (socket &optional (blocking nil))
  "Accept a connection on SOCKET and return the stream associated
with the new connection.  Do not block unless BLOCKING is non-NIL"
  ;; XXX this probably races on clisp - the client can go away between
  ;; select and accept.  Dunno what allegro does
  #+cmucl-sockets
  (when blocking
    (let ((new (ext:accept-tcp-connection socket)))
      (mess 3 "Acception tcp connection: ~S" new)
      (setq new (system:make-fd-stream new
                             :input t :output t :element-type
                             '(unsigned-byte 8)))
      (mess 2 " - to stream: ~S" new)
      new))
  ;;  (error "non-blocking accept() not yet implemented for cmucl sockets")
  #+db-sockets
  (let ((before (sockets:non-blocking-mode socket)))
    (unwind-protect
        (handler-case
            (progn
              (setf (sockets:non-blocking-mode socket) (not blocking))
              (let ((k (sockets:socket-accept socket)))
                (setf (sockets:non-blocking-mode k) nil)
                (sockets:socket-make-stream k :element-type '(unsigned-byte 8)
                                            :input t :output t )))
          (sockets::interrupted-error nil))
      (setf (sockets:non-blocking-mode socket) before)))
  #+clisp 
  (when (lisp:socket-wait socket 0 10)
    (let* ((conn (lisp:socket-accept socket 
                                     :element-type '(unsigned-byte 8))))
      (mess 4 "Accepting connection from ~A"
            (lisp:socket-stream-peer conn))
      conn))
  #+allegro 
  (let ((conn (socket:accept-connection socket :wait blocking)))
    (mess 4 "Accepting connection from ~A:~D"
            (socket:ipaddr-to-hostname (socket:remote-host conn))
            (socket:remote-port conn) )
    conn))


;;; coerce an unconnected-socket to something intelligible to
;;; wait-for-input-on-streams
(defun coerce-to-waitable-thing (i)
  #+allegro (if (streamp i) i (socket:socket-os-fd i))
  #-allegro i
  ;; The following is not needed right now    [lenst/2000-05-18 21:08:38]
  #|(etypecase i (stream i) (unconnected-socket))|#)


;; Check if input is directly available on (socket) stream
;; if this returns false positives and wait-for-input-on-streams
;; returns :cant the server functionallity is severly reduced :()
(defun socket-stream-listen (stream)
  (declare (ignorable stream))
  (%SYSDEP 
   "check if input is available on socket stream"
   #+clisp t                            ; Ouch!
   (listen stream)))


(defun socket-close (socket)
  (%SYSDEP
   "close a listener socket"
   #+clisp 
   (lisp:socket-server-close socket)
   ;; default
   (close socket)))


(defun wait-for-input-on-streams (server-sockets streams)
  "SERVER-SOCKETS is a list of UNCONNECTED-SOCKETs.  
STREAMS is a list whose elements are STREAMs. Wait for a while,
returning as soon as one of them might be ready for input. 
Return 
  NIL - if no input available
  :SERVER SOCKET  - if unconnected-socket SOCKET can accept conn.
  :STREAM STREAM  - if input available from STREAM
  :CANT           - if the implementaion doesn't support waiting
"
  (declare (ignorable server-sockets streams))
  (%SYSDEP 
   "wait for for input on streams and sockets"

   #+allegro 
   (let ((all-waitable streams))
     (dolist (socket server-sockets)
       (push (socket:socket-os-fd socket) all-waitable))
     (let ((ready 
            (handler-case
                (mp:wait-for-input-available 
                 all-waitable
                 :timeout 20
                 :whostate "wating for CORBA input")
              (type-error (err)
                ;; Seems like this can happen if the other end is
                ;; closing the socket. The caller should remove these
                ;; streams before calling again!
                (mess 3 "Error while waiting for input: ~A" err)
                nil))))
       (if (not ready)
           nil
         (if (member (car ready) streams)
             (values :stream (car ready))
           (values :server
                   (loop for s in server-sockets
                       when (eql (car ready) (socket:socket-os-fd s)) 
                       return s))))))
   
   ;; Default
   (progn (sleep 0.01)
          :cant)))
