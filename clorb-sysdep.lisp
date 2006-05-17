;;;; clorb-sysdep.lisp
;; most system dependent code is collected here
;; - TCP/IP sockets implementation glue
;; - interface to select (or poll) functionality
;; - read/write of octet sequences, blocking and non-blocking
;; - multi processing
;; - external programs
;; - octets <-> characters

(in-package :clorb)


;;; Frob with the *features* to make this all a bit easier.

#+digitool
(eval-when (:compile-toplevel :execute :load-toplevel)
  #-clorb-mcl-task-evaluator
  (progn 
    (pushnew 'clorb::mcl-bsd *features*)
    (cond ((find-package "BSD"))
          ((find-package "NET.CDDR.PACKER")
           (funcall (intern "REQUIRE-PACKAGE" "NET.CDDR.PACKER") "BSD"))
          (t
           (require "BSD")))))
  


;;; The :sockets (db-sockets) library can be used in CMUCL or SBCL:
;;; it's optional (though desirable) in the former, which otherwise
;;; uses its usual socket support (cmucl-sockets).  In SBCL we have
;;; no other option

;;; Added support for SB-BSD-SOCKETS in SBCL. It seems to be a
;;; standard contrib package.

#+(or cmu sbcl)
(eval-when (:compile-toplevel :load-toplevel)
  (cond ((find-package "SOCKETS")
         (pushnew 'clorb::db-sockets *features*))
        ((find-package "SB-BSD-SOCKETS")
         (pushnew 'clorb::sb-bsd-sockets *features*))
        (t
         #+cmu (pushnew 'clorb::cmucl-sockets *features*)
         #+sbcl
         (progn
           (require :sb-bsd-sockets)
           (pushnew 'clorb::sb-bsd-sockets *features*)           
           (unless (find-package "SB-BSD-SOCKETS")
             (error "We need the SOCKETS library; SBCL doesn't have its own")           )))))


(defmacro %sysdep (desc &rest forms)
  (when (null forms)
      (error "No system dependent code to ~A" desc))
  (car forms))


;;;; SBCL - serve event support
;; 	From: 	  yavannadil@yahoo.com
;;	Subject: 	OP:RUN and REPL
;;	Date: 	30 december 2005 15:45:23 MET

(defvar *repl-friendly* nil)

(defun make-repl-happy ()
  (%SYSDEP
   "makes necessary setup to leave REPL free"
   #+sbcl
   (handler-bind
       ((error #'(lambda (c)
                   (declare (ignore c))
                   (invoke-restart (find-restart 'continue)))))
     (setf *repl-friendly* t
           ;; Automatically remove closed sockets
           (fdefinition 'sb-impl::handler-descriptors-error)
           #'(lambda ()
               (dolist (handler sb-impl::*descriptor-handlers*)
                 (unless (or (sb-impl::handler-bogus handler)
                             (sb-unix:unix-fstat
                              (sb-impl::handler-descriptor handler)))
                   (setf (sb-impl::handler-bogus handler) t)))
               (setf sb-impl::*descriptor-handlers*
                     (delete-if #'sb-impl::handler-bogus
                                sb-impl::*descriptor-handlers*)))))
   ;; Default
   (setf *repl-friendly* t)))

(defun make-repl-friendly (s)
  (when *repl-friendly*
    (%SYSDEP
     "adds callbacks for socket"
     #+sbcl
     (sb-sys:add-fd-handler
      (sb-bsd-sockets:socket-file-descriptor s)
      :input
      #'(lambda (fd)
          (declare (ignore fd))
          (loop while (op:work_pending *the-orb*)
             do (op:perform_work *the-orb*))))

     ;; Default - ignore
     (progn s))))


;;;; TCP/IP sockets implementation glue

#+digitool
(require "OPENTRANSPORT")

#+digitool
(defclass MCL-LISTENER-SOCKET ()
  ((port :initarg :port :accessor mcl-listener-port)
   (stream :initform nil :accessor listener-stream)))


#+clisp
(defvar *clisp-buffered-streams* nil
  "If connections used buffered streams.")


;; the unconnected socket is returned by OPEN-PASSIVE-SOCKET and used
;; in ACCEPT-CONNECTION-ON-PORT and COERCE-TO-WAITABLE-THING

(defun open-passive-socket (port)
  "Returns an UNCONNECTED-SOCKET for a TCP socket listening on PORT.  Set SO_REUSEADDDR if possible"
  (%SYSDEP
   "open listener socket"

   #+dummy-tcp
   (list 'dummy-listener (or port 115577))

   #+(or allegro use-acl-socket)
   (socket:make-socket :connect :passive :local-port port
                       :format :binary :reuse-address t)

   #+openmcl
   (openmcl-socket:make-socket :connect :passive :local-port port
                               :format :binary :reuse-address t)

   #+clisp 
   (if port (ext:socket-server port) (ext:socket-server))

   #+clorb::cmucl-sockets 
   (ext:create-inet-listener (or port 0))

   #+clorb::db-sockets
   (let ((s (sockets:make-inet-socket :stream :tcp)))
     (setf (sockets:sockopt-reuse-address s) t)
     (sockets:socket-bind s #(0 0 0 0) (or port 0))
     (sockets:socket-listen s 5)
     s)

   #+clorb::sb-bsd-sockets
   (let ((s (make-instance 'sb-bsd-sockets:inet-socket
                           :type :stream :protocol :tcp)))
     (setf (sb-bsd-sockets:sockopt-reuse-address s) t)
     (sb-bsd-sockets:socket-bind s #(0 0 0 0) (or port 0))
     (sb-bsd-sockets:socket-listen s 5)
     (make-repl-friendly s)
     s)

   #+digitool
   (let ((listener (make-instance 'mcl-listener-socket :port port)))
     (accept-connection-on-socket listener)
     listener)))


;; name of local host from passive socket, this is the local host, and
;; will be used to default the hostname used in object references

(defun passive-socket-host (socket)
  (declare (ignorable socket))
  (%SYSDEP
   "Get the hostname/IP of socket"

   #+dummy-tcp
   "localhost"

   #+clisp
   (ext:socket-server-host socket)

   #+(or Allegro use-acl-socket)
   (socket:ipaddr-to-hostname (socket:local-host socket))

   #+digitool
   (let ((host (ccl::stream-local-host (listener-stream socket))))
     (handler-case
       (if (zerop host)
         "localhost"
         (ccl::inet-host-name host))
       (ccl::tcp-unknown-domain-name 
        nil
        (ccl::tcp-addr-to-str host))))

   #+openmcl
   (or (ignore-errors (openmcl-socket:ipaddr-to-hostname
                       (openmcl-socket:local-host socket)))
       "localhost")

   ;; Default
   "localhost"))



;; the port of a passive socket, will be used in object references

(defun passive-socket-port (socket)
  (declare (ignorable socket))
  (%SYSDEP
   "Get the port of socket"

   #+dummy-tcp
   (second socket)

   #+clisp
   (ext:socket-server-port socket)

   #+(or Allegro use-acl-socket)
   (socket:local-port socket)

   #+openmcl
   (openmcl-socket:local-port socket)

   #+clorb::db-sockets
   (multiple-value-bind (adr port)
       (sockets:socket-name socket)
     (declare (ignore adr))
     port)

   #+clorb::sb-bsd-sockets
   (multiple-value-bind (adr port)
       (sb-bsd-sockets:socket-name socket)
     (declare (ignore adr))
     port)

   #+cmu
   (nth-value 1 (ext:get-socket-host-and-port socket))

   #+digitool
   (mcl-listener-port socket)))




(defparameter *connect-timeout* 120)

(defun open-active-socket (host port &optional (binary t))
  "Open a TCP connection to HOST:PORT, and return the stream asociated with it"
  (let ((type (if binary '(unsigned-byte 8) 'base-char)))
    (declare (ignorable type))
    (%SYSDEP
     "open socket to host/port"

     #+dummy-tcp
     (error "Dummy TCP cannot connect")

     #+clisp 
     (ext:socket-connect port host :element-type type
                         :buffered *clisp-buffered-streams*)

     #+clorb::cmucl-sockets
     (system:make-fd-stream (ext:connect-to-inet-socket host port)
                            :input t :output t :element-type type)

     #+clorb::db-sockets
     (let ((s (sockets:make-inet-socket :stream :tcp))
           (num (car (sockets:host-ent-addresses
                      (sockets:get-host-by-name host)))))
       (sockets:socket-connect s num port)
       (sockets:socket-make-stream s :element-type type
                                   :input t :output t :buffering :none))
     #+clorb::sb-bsd-sockets
     (let ((s (make-instance 'sb-bsd-sockets:inet-socket
                             :type :stream :protocol :tcp))
           (num (sb-bsd-sockets:host-ent-address
                 (sb-bsd-sockets:get-host-by-name host))))
       (sb-bsd-sockets:socket-connect s num port)
       (sb-bsd-sockets:socket-make-stream s :element-type type
                                   :input t :output t :buffering :none))

     #+(or allegro use-acl-socket)
     (socket:make-socket 
      :remote-host host :remote-port port
      :format (if binary :binary :text))

     #+openmcl
     (openmcl-socket:make-socket 
      :remote-host host :remote-port port
      :format (if binary :binary :text))

     #+digitool
     (ccl::open-tcp-stream host port :element-type type 
                           :connect-timeout *connect-timeout*))))


(defun socket-peer (conn)
  "Returns: host port"
  (declare (ignorable conn))
  (%SYSDEP
   "Get host port for peer"
    #+(or allegro use-acl-socket)
    (values
     (or (ignore-errors (acl-socket:ipaddr-to-hostname (acl-socket:remote-host conn)))
         (acl-socket:ipaddr-to-dotted (acl-socket:remote-host conn)))
     (acl-socket:remote-port conn))
    #+openmcl
    (values (let ((host (openmcl-socket:remote-host conn)))
              (and host
                   (or (ignore-errors
                         (openmcl-socket:ipaddr-to-hostname host))
                       (openmcl-socket:ipaddr-to-dotted host))))
            (ignore-errors (openmcl-socket:remote-port conn)))
    #+Digitool
    (values (let ((host (ccl::stream-remote-host conn)))
              (ccl::tcp-addr-to-str host)
              #+(or)
              (ccl::inet-host-name host))
            (ccl::stream-remote-port conn))
    #+clisp
    (values (ext:socket-stream-host conn)
            (ext:socket-stream-port conn))
   
   ;; Default
   nil ))

(defun accept-connection-on-socket (socket &optional (blocking nil))
  "Accept a connection on SOCKET and return the stream associated
with the new connection.  Do not block unless BLOCKING is non-NIL"
  (declare (ignorable blocking))
  (%SYSDEP
   "accept a connection"

   #+dummy-tcp
   nil

   #+clorb::cmucl-sockets
   (when blocking
     (let ((new (ext:accept-tcp-connection socket)))
       (mess 3 "Accepting tcp connection: ~S" new)
       (setq new (system:make-fd-stream new
                                        :input t :output t :element-type
                                        '(unsigned-byte 8)))
       (mess 2 " - to stream: ~S" new)
       new))
   ;;  (error "non-blocking accept() not yet implemented for cmucl sockets")

   #+clorb::db-sockets
   (let ((before (sockets:non-blocking-mode socket)))
     (unwind-protect
          (handler-case
              (progn
                (setf (sockets:non-blocking-mode socket) (not blocking))
                (let ((k (sockets:socket-accept socket)))
                  (when k
                    (setf (sockets:non-blocking-mode k) nil)
                    (sockets:socket-make-stream k
                                                :element-type '(unsigned-byte 8)
                                                :input t :output t ))))
            (sockets::interrupted-error nil))
       (setf (sockets:non-blocking-mode socket) before)))

   #+clorb::sb-bsd-sockets
   (let ((before (sb-bsd-sockets:non-blocking-mode socket)))
     (unwind-protect
         (handler-case
             (progn
               (setf (sb-bsd-sockets:non-blocking-mode socket) (not blocking))
               (let ((k (sb-bsd-sockets:socket-accept socket)))
                 (when k
                   (setf (sb-bsd-sockets:non-blocking-mode k) nil)
                   (make-repl-friendly k)
                   (sb-bsd-sockets:socket-make-stream
                    k :element-type '(unsigned-byte 8)
                    :input t :output t ))))
           (sb-bsd-sockets:interrupted-error nil))
       (setf (sb-bsd-sockets:non-blocking-mode socket) before)))

   #+clisp 
   (when (ext:socket-wait socket (if blocking 10 0))
     (let* ((conn (ext:socket-accept socket 
                                 :element-type '(unsigned-byte 8)
                                 :buffered *clisp-buffered-streams*)))
       (mess 4 "Accepting connection from ~A"
             (ext:socket-stream-peer conn))
       conn))

   #+(or allegro use-acl-socket)
   (let ((conn (socket:accept-connection socket :wait blocking)))
     (when conn
       (mess 4 "Accepting connection from ~A:~D"
             (or (ignore-errors
                  (socket:ipaddr-to-hostname (socket:remote-host conn)))
                 (acl-socket:ipaddr-to-dotted (socket:remote-host conn)))
             (socket:remote-port conn)))
     conn)

   #+openmcl
   (let ((conn (openmcl-socket:accept-connection socket :wait blocking)))
     (when conn
       (mess 4 "Accepting connection ~S" conn))
     conn)

   #+digitool
   (let* ((s (listener-stream socket)))
     (when (and s blocking)
       (flet ((ready-p (s)
                (not (eql (ccl::opentransport-stream-connection-state s) :unbnd))))
         (unless (ready-p s)
           (ccl:process-wait "waiting" #'ready-p s))))

     (let ((state (and s (ccl::opentransport-stream-connection-state s)))
           (new nil))
       
       (when (member state '(:incon :dataxfer))
         (mess 3 "Accepting connection ~S" s)
         (setq new s
               state nil))
       (when (member state '(nil :uninit :closed))
         (mess 3 "New listener replacing ~S" s)
         (or (mcl-listener-port socket)
             (error "MCL OpenTransport needs explicit port number for listener socket"))
         (setf (listener-stream socket)
               (ccl::open-tcp-stream nil (mcl-listener-port socket) 
                                     :element-type '(unsigned-byte 8)
                                     :reuse-local-port-p t)))
       new))))


(defun socket-stream-closed-p (stream)
  (%SYSDEP
   "check if the stream has been closed (by other side presumably)"

   #+digitool
   (let ((state (ccl::opentransport-stream-connection-state stream)))
     (not (member state '(:outcon :dataxfer))))

   ;; Default, assume it is not closed
   (null stream)))


;; Check if input is directly available on (socket) stream
;; or eof, or other error.
(defun socket-stream-listen (stream)
  (declare (ignorable stream))
  (%SYSDEP 
   "check if input is available on socket stream"

   #+clisp
   (ext:read-byte-lookahead stream)

   #+CCL
   (or (listen stream)
       (ccl:stream-eofp stream)
       (socket-stream-closed-p stream))

   ;; Default
   (listen stream))) 

(defun socket-close (socket)
  (%SYSDEP
   "close a listener socket"

   #+clisp 
   (ext:socket-server-close socket)

   #+clorb::sb-bsd-sockets
   (sb-bsd-sockets:socket-close socket)

   ;; default
   (close socket)))


;;;; HTTP GET

(defun http-get-ior (host port path)
  (%SYSDEP
   "get IOR from http server"
   (with-open-stream (s (open-active-socket host port nil))
     (let ((crlf (coerce (vector #\Return #\Linefeed) 'string)))
       (format s "GET ~A~A" path crlf)
       (force-output s)
       (let ((ior (read-line s)))
         (cond 
          ((and (stringp ior)
                (> (length ior) 4)
                (string= "IOR:" ior :end2 4))
           (setq ior (string-right-trim crlf ior)))
          (t
           (mess 4 "Non IOR from http://~A:~A~A~% >> ~S" 
                 host port path ior)
           nil)))))))


;;;; Select interface
;;(make-select) => y
;;(select-reset y)
;;(select-add-listener y s)
;;(select-add-stream y s input output cookie)
;;(select-wait y) => y'
;;(select-do-result y' func)
;; where: (func cookie status)


(%SYSDEP
 "make select obj"

 #+(or sbcl cmu18 cmu19 openmcl)
 (defstruct SELECT
   (fds  nil)
   (cookies nil)
   (direct-input nil)
   (rset 0)
   (wset 0)
   (maxn 0 :type fixnum))

 (defstruct (SELECT (:constructor make-select))
   (value   nil)
   (cookies nil)
   (streams nil)
   (writepending nil))
 )

#+(or sbcl cmu18 cmu19 openmcl)
(defmacro %add-fd (select-obj fd-number set)
  (let ((sobj '#:sobj)
        (fd   '#:fd))
    `(let ((,sobj ,select-obj)
           (,fd   ,fd-number))
      (declare (fixnum ,fd))
      (setf (select-maxn ,sobj)
       (max (select-maxn ,sobj) ,fd))
      (setf (,set ,sobj) (logior (,set ,sobj) (ash 1 ,fd))))))

#+(or sbcl cmu18 cmu19 openmcl)
(defmacro %socket-file-descriptor (socket)
  (%SYSDEP
   "file descriptor for listener socket"
   #+clorb::db-sockets `(sockets:socket-file-descriptor ,socket)
   #+clorb::sb-bsd-sockets `(sb-bsd-sockets:socket-file-descriptor ,socket)
   #+(or cmu18 cmu19) socket
   #+openmcl `(ccl::socket-device ,socket)))

#+(or sbcl cmu18 cmu19 openmcl)
(defmacro %stream-fd (stream)
  (%SYSDEP
   "file descriptor for stream"
   #+(or cmu18 cmu19) `(system:fd-stream-fd ,stream)
   #+sbcl  `(sb-sys:fd-stream-fd ,stream)
   #+openmcl `(ccl::socket-device ,stream)))

#+(or sbcl cmu18 cmu19 openmcl)
(defmacro %unix-select (maxn rset wset xset timeout)
  `(#+sbcl sb-unix:unix-select #+(or cmu18 cmu19) unix:unix-select
           #+openmcl unix-select
           ,maxn ,rset ,wset ,xset ,timeout))

#+openmcl
(defun unix-select (maxn rset wset xset timeout-sec &optional (to-usecs 0))
  (ccl::rletZ ((tv :timeval))
    (when timeout-sec
      (setf (ccl:pref tv :timeval.tv_sec) timeout-sec
            (ccl:pref tv :timeval.tv_usec) to-usecs))
    (ccl::%stack-block ((outfds ccl::*fd-set-size*)
                        (inpfds ccl::*fd-set-size*)
                        (errfds ccl::*fd-set-size*))
      (ccl::fd-zero outfds)
      (ccl::fd-zero inpfds)
      (ccl::fd-zero errfds)
      (loop for fd from 0 to maxn 
           when (logbitp fd wset) do (ccl::fd-set fd outfds)
           when (logbitp fd rset) do (ccl::fd-set fd inpfds)
           when (logbitp fd xset) do (ccl::fd-set fd errfds))
      (let* ((res (#_select maxn inpfds outfds errfds
			    (if timeout-sec tv (ccl::%null-ptr)))))
        (setq wset 0 rset 0 xset 0)
        (when (> res 0)
          (loop for fd from 0 to maxn 
               do (when (ccl::fd-is-set fd inpfds)
                    (setf rset (logior rset (ash 1 fd))))
               do (when (ccl::fd-is-set fd outfds)
                    (setf wset (logior wset (ash 1 fd))))
               do (when (ccl::fd-is-set fd errfds) 
                    (setf xset (logior xset (ash 1 fd))))))
        (values res rset wset xset)))))
  

(defun select-add-listener (select socket)
  (declare (ignorable select socket))
  (%SYSDEP
   "add listener to select"

   #+clisp
   (progn
     (push socket (select-value select))
     (push nil (select-cookies select)))

   #+(or sbcl cmu18 cmu19 openmcl)
   (%add-fd select (%socket-file-descriptor socket) select-rset)

   #+allegro
   (push (socket:socket-os-fd socket) (select-value select))

   ;; Default
   nil))


(defun select-listener (select socket)
  (declare (ignorable select socket)) 
  (%SYSDEP
   "listener ready in select result"

   #+(or sbcl cmu18 cmu19 openmcl)
   (and (not (select-direct-input select))
        (logbitp (%socket-file-descriptor socket)
                 (select-rset select)))

   ;; Default
   nil))


(defun select-add-stream (select stream input output cookie)
  "Add STREAM to SELECT for INPUT and/or OUTPUT.
Returns cookie that should be used after select-wait to get
status for stream."
  (declare (ignorable select stream input output)
           (optimize (speed 2)))
  (%SYSDEP
   "add stream to select"

   #+clisp
   (progn
     (push
      (cons stream
            (cond ((not input)  :output)
                  ((not output) :input)
                  (t            :io)))
      (select-value select))
     (push cookie (select-cookies select)))

   #+(or cmu18 cmu19 sbcl openmcl)
   (let ((fd (%stream-fd stream)))
     (declare (fixnum fd))
     (when input
       ;; there is buffering in the stream, need to empty the buffer
       ;; before doing a real select
       (when (socket-stream-listen stream)
         ;; FIXME: listen can signal error!
         (push cookie (select-direct-input select)))
       (%add-fd select fd select-rset))
     (when output
       (%add-fd select fd select-wset))
     (push fd (select-fds select))
     (push cookie (select-cookies select)))

   #+(or allegro)
   (progn
      (when output
        (setf (select-writepending select) t))
      (when input
        (push stream (select-value select)))
      (push stream (select-streams select))
      (push cookie (select-cookies select)))

   ;; Default
   (progn
     (let ((read-ready
            (if input (socket-stream-listen stream))))
       (when (or output read-ready)
         (setf (select-writepending select) t))
       (push cookie (select-cookies select))
       (push (if read-ready
                 (if output :io :input)
                 (if output :output nil))
             (select-value select)))) ))


(defun select-wait (select poll)
  "Wait for selected streams.
Returns select result to be used in getting status for streams."
  (%SYSDEP
   "wait on selected streams"

   #+clisp
   (progn
     (mess 1 "Selecting ~A" select)
     (let ((select-list (select-value select)))
       (when select-list
         (setf (select-value select) (ext:socket-status select-list (if poll 0 60)))))
     (mess 1 "Select result ~A" (select-value select))
     select)

   #+allegro
   (progn
     (setf (select-value select)
           (mp:wait-for-input-available
            (select-value select)
            :timeout (if (or poll (select-writepending select)) 0 20)
            :whostate "wating for CORBA input"))
     select)

   #+(or cmu18 cmu19 sbcl openmcl)
   (progn
     (unless (select-direct-input select)
       (mess 2 "Enter select ~A ~A"
             (select-rset select) (select-wset select))
       (multiple-value-bind (result rset wset xset)
           (%unix-select (1+ (select-maxn select))
                         (select-rset select)
                         (select-wset select)
                         0 (if poll 0 200))
         (declare (ignorable xset))
         ;;FIXME: should perhaps use xset
         (mess 2 "Select return ~A ~A ~A ~A" result rset wset xset)
         (setf (select-rset select) rset)
         (setf (select-wset select) wset)))
     select)


   ;; Default
   (progn
     (unless (or poll (select-writepending select))
       (sleep 0.02))
     select)))


(defun select-do-result (select func)
  (%SYSDEP
   "loop thru result of a select"

   #+clisp
   (loop for cookie in (select-cookies select)
        for status in (select-value select)
        when (and cookie status)
        do (funcall func cookie status))

   #+allegro
   (loop for cookie in (select-cookies select)
        for stream in (select-streams select)
        do (funcall func cookie
                    (if (member stream (select-value select))
                        :io :output)))

   #+(or sbcl cmu18 cmu19 openmcl)
   (if (select-direct-input select)
       (loop for cookie in (select-direct-input select)
            do (funcall func cookie :input))
       (loop
          with rset = (select-rset select)
          with wset = (select-wset select)
          for cookie in (select-cookies select)
          for fd in (select-fds select)
          do (let ((status (if (logbitp fd rset)
                               (if (logbitp fd wset) :io :input)
                               (if (logbitp fd wset) :output nil))))
               (when status (funcall func cookie status)))))

   ;; Default
   (loop for cookie in (select-cookies select)
        for status in (select-value select)
        do (funcall func cookie status))))

;;;; Read / Write 

(deftype octets () `(vector (unsigned-byte 8)))
(deftype index () '(integer 0 #.array-dimension-limit))


(defun read-octets (seq start end stream)
  ;; read octets into seq from start to end
  (declare (optimize speed)
           (type octets seq)
           (type index start end))
  #+Digitool
  (unless (socket-stream-listen stream)
    ;; Don't start reading until input is available, becuase MCL
    ;; can't do read and write on the same stream due to a locking issue.
    (process-wait-with-timeout "wait for input" nil
                               #'socket-stream-listen stream))
  (let ((n (read-sequence seq stream :start start :end end)))
    (when (< n (- end start))
      (error 'end-of-file :stream stream))))


(defun read-octets-no-hang (seq start end stream)
  ;; read octets into seq from start to end, may stop reading before end
  ;; if would hang return number of octets read
  (declare (optimize speed)
           (type octets seq)
           (type index start end))
  (let ((read-pos start))
    (declare (type index read-pos))
    (%SYSDEP
     "read many octets without hanging"

     #+clisp
     (progn
       (setq read-pos (ext:read-byte-sequence seq stream
                                              :start start :end end :no-hang t))
       (if (and (= read-pos start)
                (eql :eof (ext:read-byte-lookahead stream )))
           (error 'end-of-file :stream stream)))

     #+openmcl
     (loop ;; assume at least first byte should be readable
        do (setf (aref seq read-pos) (read-byte stream))
          (incf read-pos)
        until (or (= read-pos end)
                  (not (socket-stream-listen stream))))

     ;; Default
     (loop while (socket-stream-listen stream)
           do (setf (aref seq read-pos) (read-byte stream))
           (incf read-pos)
           until (= read-pos end)))

    ;; Common end:
    (- read-pos start)))


(defun write-octets (seq start end stream)
  "Write octets from SEQ between START and END to the STREAM.
Returns when all the data has been written."
  (declare (type octets seq)
           (type index start end))
  (write-sequence seq stream :start start :end end)
  (force-output stream))


(defun write-octets-no-hang (seq start end stream)
  "returns number of octets written"
  (%SYSDEP
   "write octets without hanging"

   ;; Default is possibly blocking
   (progn
     (write-sequence seq stream :start start :end end)
     (force-output stream)
     (- end start))))



;;;; Multi process support

(defun current-process ()
  (%SYSDEP
   "return the current process"
   #+(or mcl openmcl) ccl:*current-process*
   #+sb-thread sb-thread:*current-thread*
   :current-process))

(defun start-process (options proc &rest args)
  (declare (ignorable options))
  (%SYSDEP
   "start a process"
   #+(or mcl openmcl)
   (apply #'ccl:process-run-function options proc args)
   #+sb-thread
   (sb-thread:make-thread (lambda () (apply proc args)) :name options)
   #+acl-compat
   (apply #'acl-compat.mp:process-run-function name func args)
   ;; Default: just do it
   (progn (apply proc args)
          nil)))

(defun end-process (process)
  (and process
       (%SYSDEP "end process"
                #+openmcl
                (ccl:process-kill process)
                #+mcl (ccl:process-reset process nil :kill)
                #+sb-thread (sb-thread:terminate-thread process)
                #+acl-compat
                (acl-compat.mp:process-kill process)
                nil)))

(defun process-running-p (process)
  (%SYSDEP "check if process is running"
           #+openmcl (member process (ccl:all-processes))
           #+mcl (ccl:process-active-p process)
           ;; (ccl::process-exhausted-p ??)
           #+sb-thread (sb-thread:thread-alive-p process)
           #+acl-compat
           (acl-compat.mp:process-active-p process)
           nil))


(defun process-wait-with-timeout (whostate timeout wait-func &rest args)
  (declare (ignorable whostate timeout wait-func args))
  (%SYSDEP
   "suspend process until function returns true"
   #+mcl
   (apply #'ccl:process-wait-with-timeout whostate timeout wait-func args)

   ;; Default: ignore
   nil ))

(defun process-wait (whostate wait-func &rest args)
  (declare (ignorable whostate))
  (%SYSDEP
   "wait for condition to come true"
   #+(or mcl openmcl) 
   (apply #'ccl:process-wait whostate wait-func args)

   ;; Default
   (loop until (apply wait-func args)
         do (sleep 0.1))))


(defun make-lock (name)
  (%SYSDEP "make synchronization lock"
           #+(or mcl openmcl)
           (ccl:make-lock name)
           #+sb-thread
           (sb-thread:make-mutex :name name)
           #+acl-compat
           (acl-compat.mp:make-process-lock :name name)
           ;; Default
           `(:lock , name)))


(defmacro with-lock (lock &body body)
  "Execute body with lock held"
  (%SYSDEP
   "execute body with lock held"
   #+(or mcl openmcl)
   `(ccl:with-lock-grabbed (,lock) ,@body)
   #+sb-thread
   `(sb-thread:with-mutex (,lock) ,@body)
   ;; Default
   `(progn ,@body)))



;;;; Execution Queue


(defclass execution-queue ()
  ((max-processes :initarg :max-processes :initform 10   :accessor max-processes)
   (max-idle      :initarg :max-idle      :initform nil  :accessor max-idle)
   (queue                                 :initform nil  :accessor eq-queue)
   (idle-count                            :initform 0    :accessor idle-count)
   (idle-list     :initarg :idle-list     :initform nil  :accessor idle-list)
   (process-list  :initarg :process-list  :initform nil  :accessor process-list)
   (process-count :initarg :process-count :initform 0    :accessor process-count)
   (eq-lock        :initform (make-lock "eq-lock")       :reader eq-lock)
   (executor      :initarg :executor  :initform 'eq-exec :accessor executor)
   (name-template :initarg :name-template :initform "eq" :accessor name-template)
   (name-count    :initarg :name-count    :initform 0    :accessor name-count)
   #+OpenMCL
   (semaphore      :initform (ccl:make-semaphore)        :reader semaphore)
   #+sb-thread
   (waitqueue      :initform (sb-thread:make-waitqueue)  :reader waitqueue)))


(defmacro with-execution-queue (q &body body)
  `(with-accessors ((max-processes max-processes) (max-idle max-idle)
                    (queue eq-queue) (idle-count idle-count)
                    (process-list process-list) (process-count process-count)
                    (lock eq-lock) (executor executor) (name-template name-template)
                    (name-count name-count) (idle-list idle-list)
                    #+OpenMCL (semaphore semaphore)
                    #+sb-thread (waitqueue waitqueue))
                   ,q
     ,@body))


(defmethod next-process-name ((q execution-queue))
  (with-execution-queue q
    (format nil "~A ~D" name-template (incf name-count))))


#+Digitool
(defun eq-main (q obj)
  (with-execution-queue q
    (loop
      (funcall executor obj)
      (ccl:with-lock-grabbed (lock)
        (cond (queue
               (setq obj (pop queue)))
              ((or (null max-idle) (< idle-count max-idle))
               (incf idle-count)
               (push ccl:*current-process* idle-list)
               (return))
              (t
               (decf process-count)
               (setq process-list (delete ccl:*current-process* process-list))
               (ccl:process-kill ccl:*current-process*)
               (return)))))))

#+OpenMCL
(defun eq-main (q obj)
  (with-execution-queue q
    (let ((idle nil))
      (loop
         (cond (idle
                (ccl:wait-on-semaphore semaphore)
                (ccl:with-lock-grabbed (lock)
                  (when queue
                    (setq idle nil
                          obj (pop queue))
                    (decf idle-count)
                    (deletef (current-process) idle-list))))
               (t
                (handler-case
                    (funcall executor obj)
                  (serious-condition (condition)
                    (mess 4 "Thread fails: ~A" condition)
                    (ccl:with-lock-grabbed (lock)
                      (decf process-count)
                      (deletef (current-process) process-list)
                      (return))))
                (ccl:with-lock-grabbed (lock)
                  (let ((process (current-process)))
                    (cond (queue
                           (setq obj (pop queue)))
                          ((or (null max-idle) (< idle-count max-idle))
                           (incf idle-count)
                           (setq idle t)
                           (push process idle-list))
                          (t
                           (decf process-count)
                           (deletef process process-list)
                           (end-process process)
                           (return)))))))))))


#+sb-thread
(defun eq-main (q obj)
  (with-execution-queue q
    (let ((idle nil))
      (loop
         (cond (idle
                (with-lock lock
                  (sb-thread:condition-wait waitqueue lock)
                  (when queue
                    (setq idle nil
                          obj (pop queue))
                    (decf idle-count)
                    (deletef (current-process) idle-list))))
               (t
                (handler-case
                    (funcall executor obj)
                  (serious-condition (condition)
                    (mess 4 "Thread fails: ~A" condition)
                    (with-lock lock
                      (decf process-count)
                      (deletef (current-process) process-list))
                    (return)))
                (with-lock lock
                  (let ((process (current-process)))
                    (cond (queue
                           (setq obj (pop queue)))
                          ((or (null max-idle) (< idle-count max-idle))
                           (incf idle-count)
                           (setq idle t)
                           (push process idle-list))
                          (t
                           (decf process-count)
                           (deletef process process-list)
                           (return)))))))))))


(defun eq-exec (obj)
  (etypecase obj
    (function (funcall obj))
    (cons (apply (car obj) (cdr obj)))))


#+Digitool
(defmethod enqueue ((q execution-queue) obj)
  (with-execution-queue q
    (ccl:with-lock-grabbed (lock)
      (cond ((not (zerop idle-count))
             (let ((p (pop idle-list)))
               (ccl:process-preset p #'eq-main q obj)
               (decf idle-count)
               (ccl:process-enable p)
               t))
            ((< process-count max-processes)
             (let ((p (ccl:make-process (next-process-name q))))
               (ccl:process-preset p #'eq-main q obj)
               (push p process-list)
               (incf process-count)
               (ccl:process-enable p)
               t))
            (t 
             (setf queue (nconc queue (list obj)))
             nil)))))

#+(or OpenMCL sb-thread)
(defmethod enqueue ((q execution-queue) obj)
  (with-execution-queue q
    (with-lock lock
      (cond ((and (zerop idle-count) (< process-count max-processes))
             (let ((p (start-process (next-process-name q) #'eq-main q obj)))
               (push p process-list)
               (incf process-count)
               t))
            (t 
             (setf queue (nconc queue (list obj)))
             #+openmcl (ccl:signal-semaphore semaphore)
             #+sb-thread (sb-thread:condition-notify waitqueue)
             nil)))))

#+(or OpenMCL sb-thread)
(defun garb-threads (q)
  (with-execution-queue q
    (with-lock lock
      (setq process-list
            (remove-if (lambda (p)
                         (unless (process-running-p p)
                           (decf process-count)
                           t))
                       process-list)))))




;;;; Running external programs

(defun shell-to-stream (command stream)
  (%SYSDEP
   "execute shell command with output to stream"
   #+openmcl
   (ccl:run-program "/bin/bash" (list "-c" command) :output stream)
   #+cmu
   (ext:run-program "/bin/sh" (list "-c" command) :output stream)
   #+sbcl
   (sb-ext:run-program "/bin/sh" (list "-c" command) :output stream
                       :error *terminal-io*)
   ;; Default
   (error "No implementation for SHELL-TO-STREAM: ~S ~A" command stream)))


(defun shell-to-string (command)
  (%SYSDEP
   "Run a command in shell with output to string"

   #+(or cmu openmcl sbcl)
   (with-output-to-string (out)
     (shell-to-stream command out))

   #+clorb::mcl-bsd
   (bsd:system-command command)

   #+clorb-mcl-task-evaluator
   (let ((string
          (ccl:send-eval (format nil "#!/bin/sh~A~A" #\Newline command)
                         "JGTaskEvaluator")))
     (substitute #\Newline #\LineFeed string))

   #+clisp 
   (with-output-to-string (out)
     (let ((shell-stream (ext:make-pipe-input-stream command)))
       (loop for c = (read-char shell-stream nil nil)
           while c do (princ c out))
       (close shell-stream)))

   #+excl
   (with-output-to-string (out)
     (multiple-value-bind (shell-stream error-stream process)
         (excl:run-shell-command command :wait nil :output :stream )
       (loop for c = (read-char shell-stream nil nil)
           while c do (princ c out))
       (when process
         (loop (when (sys:reap-os-subprocess :pid process :wait nil)
                 (return))))
       (close shell-stream)
       (when error-stream (close error-stream))))
   
   (error "No implementation for SHELL-TO-STRING: ~S" command)))


(defun external-namestring (pathname)
  (setq pathname (truename pathname))
  (%SYSDEP "convert pathname to a namestring suitable for external programs"
           #+digitool
           (if (ccl::using-posix-paths-p)
             (ccl::posix-namestring pathname)
             (namestring pathname))
           ;; Default
           (namestring pathname)))


(defun cpp-command-string (file include-directories &optional defines)
  (format nil
          #-MCL "cpp -w -undef~{ -I'~A'~}~{ -D'~A'~} '~A'"
          ;; apples /usr/bin/cpp is buggy
          #+MCL "cpp -w -undef~{ -I\"'~A'\"~}~{ -D'~A'~} \"'~A'\""
          (mapcar #'external-namestring include-directories)
          defines
          (external-namestring file)))


(defun home-volume-prefix ()
  "The directory prefix for the home volume.
Usually :ABSOLUTE but for MCL there is also a volume name. 
This is needed when translating from file:-URLs."
  (%SYSDEP "home-volume-prefix"
           #+Digitool 
           (subseq (pathname-directory (truename "home:")) 0 2)
           ;; default
           '(:ABSOLUTE)))


;;;; Octets to / from characters

;; From: Dmitri Hrapof

(defun string->octets (str)
  (%SYSDEP
   "convert string to byte array"
   #+clisp
   (ext:convert-string-to-bytes str CUSTOM:*DEFAULT-FILE-ENCODING*)
   #+sb-unicode
   (sb-ext:string-to-octets str)
   (map 'vector #'char-code str)))

(defun octets->string (oct)
  (%SYSDEP
   "convert byte array to string"
   #+clisp
   (ext:convert-string-from-bytes oct CUSTOM:*DEFAULT-FILE-ENCODING*)
   #+sb-unicode
   (sb-ext:octets-to-string (coerce oct '(vector (unsigned-byte 8))))
   (map 'string #'code-char oct)))



;; clorb-sysdep.lisp ends here
