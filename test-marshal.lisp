(in-package :clorb)

(define-test-suite "Marshal test" ()
  (macrolet ((marshal-res (res &rest body)
               `(let ((buffer (get-work-buffer)))
                  ,@body
                  (ensure-equalp (buffer-octets buffer) ',res))))
    
    (define-test "Ushort 1"
        (marshal-res #(88 1) (marshal-ushort 344 buffer) ))
    
    (define-test "short 2"
        ;; ushort??  short would use the exact same marshaling code ...
        ;; but
        (marshal-res #(168 254) (marshal-ushort -344 buffer)))

    (define-test "encapsulation"
        (marshal-res 
         #(28 0 0 0                     ; encaps size
           1                            ; byte order
           0 0 0                        ; align
           5 0 0 0                      ; string size
           72 101 106 33 0              ; "Hej!" + NUL
           0 0 0                        ; align
           8 0 0 0                      ; encaps size
           1                            ; byte order
           22                           ; octet 22
           0 0                          ; align
           44 0 0 0                     ; ulong 44
           #||#)
         (marshal-add-encapsulation
          (lambda (buffer)
            (marshal-string "Hej!" buffer)
            (marshal-add-encapsulation 
             (lambda (b) 
               (marshal-octet 22 b)
               (marshal-ulong 44 b))
             buffer))
          buffer)))

    (define-test "Typecodes"
        (let* ((buffer (get-work-buffer))
               (pardesc (make-instance 'CORBA::ParameterDescription))
               (tc (any-typecode pardesc)))
          (marshal-typecode tc buffer)
          (ensure-equalp (unmarshal-ulong buffer) 15)
          (with-encapsulation buffer
            (ensure-equalp (unmarshal-string buffer)
                           "IDL:omg.org/CORBA/ParameterDescription:1.0")
            (ensure-equalp (unmarshal-string buffer)
                           "ParameterDescription")
            (ensure-equalp (unmarshal-ulong buffer) 4))

          (setf (buffer-position buffer) 0)
          (let ((new-tc (unmarshal-typecode buffer)))
            (ensure-equalp (typecode-kind tc)
                           (typecode-kind new-tc))
            (ensure-equalp
             (map 'list #'car (tcp-members (typecode-params tc))) 
             (map 'list #'car (tcp-members (typecode-params new-tc)))))))
    
    (define-test "RecursiveTypecode" ()
      (let* ((struct-filter
              (struct-typecode "IDL:LDAP/Filter:1.0"
                               "Filter"
                               :and corba:tc_null))
             (buffer
              (make-buffer :octets (make-array 400 :fill-pointer 0
                                               :element-type 'CORBA:octet))))
        (setf (second (elt (tc-members struct-filter) 0)) struct-filter)
        (marshal struct-filter CORBA:tc_TypeCode buffer)
        (let ((tc (unmarshal CORBA:tc_TypeCode buffer)))
          (ensure-equalp (op:id struct-filter) (op:id tc))
          (ensure-equalp tc (op:member_type tc 0)))))
            
    t))

