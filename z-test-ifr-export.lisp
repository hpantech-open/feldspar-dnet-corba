;; 
(in-package :clorb)

(define-test-suite "Test IFR export"
  (variables
   (orb (CORBA:ORB_init))
   (rootpoa (op:resolve_initial_references orb "RootPOA"))
   (repository (make-instance 'repository))
   (interface (op:create_interface repository
                                           "IDL:foo:1.0" "foo" "1.0"
                                           '())))

  (define-test "Object indexer"
    (let ((oi (make-instance 'object-indexer)))
      (let ((ol (list (make-instance 'interface-def)
                      "fooo"
                      (make-instance 'string-def))))
        (let ((il (loop for o in ol collect (object-index oi o))))
          (ensure (every #'integerp il))
          (loop for i in il as o in ol 
                do (ensure-eql (index-object oi i) o))))))

  (define-test "basic translate"
    (let ((ol (list 1 "fooo" '(1 2) '#(1 2))))
      (ensure-equalp (translate nil ol) ol)
      ))

  
  (define-test "create-operation-list"
    (let* ((params (list (omg.org/corba:parameterdescription
                          :name "a" :type_def (get-primitive 'long)
                          :mode :param_in)
                         (omg.org/corba:parameterdescription
                          :name "b" :type_def (get-primitive 'string)
                          :mode :param_inout)))
           (opdef (op:create_operation interface
                                      "IDL:foo/bar:1.0" "bar" "1.0"
                                      (get-primitive 'void) :op_normal
                                      params '() '()))
           (ol (create-operation-list opdef)))
        (loop for nv in ol
              for param in params
              do (ensure-equalp (op:name nv) (op:name param))
              (ensure (op:equal (any-typecode (op:argument nv)) (op:type param))
                      "equal typecode")
              (ensure-eql (logand ARG_IN (op:arg_modes nv))
                          (if (eq (op:mode param) :param_out)
                           0 ARG_IN))
              (ensure-eql (logand ARG_OUT (op:arg_modes nv))
                          (if (eq (op:mode param) :param_in)
                           0 ARG_OUT))) ))
              
  (define-test "servant-wrapper basic"
    (let* ((poa rootpoa)
           (wrapper (make-instance 'servant-wrapper
                      :orb orb :poa poa)))
      (ensure-eql (op:_default_poa wrapper) poa)
      (ensure (poa-current))
      (loop for integer in '(1 10 100 17 919)
            do (ensure-eql (oid-integer (integer-oid integer)) integer))))

  (define-test "servant-wrapper local/remote"
    (let* ((poa rootpoa)
           (wrapper (make-instance 'servant-wrapper
                      :orb orb :poa poa))
           (ri (make-remote wrapper interface)))
      (ensure-typep ri 'CORBA:Proxy)
      (ensure-eql (make-local wrapper ri) interface)
      (let* ((data (list 12 "foo" interface
                         (vector "bar" interface)))
             (rdata (make-remote wrapper data))
             (ldata (make-local wrapper rdata)))
        (ensure-equalp ldata data)
        (ensure-typep (elt rdata 2) 'omg.org/corba:interfacedef-proxy)
        (ensure-typep (elt (elt rdata 3) 1) 'CORBA:Proxy))
      (let ((struct (omg.org/corba:unionmember
                     :name "foo"
                     :label 123
                     :type CORBA:tc_string
                     :type_def (get-primitive 'string))))
        (let ((rs (make-remote wrapper struct)))
          (ensure-typep rs 'omg.org/corba:unionmember)
          (ensure-typep (op:type_def rs) 'omg.org/corba:primitivedef-proxy)
          (let ((ls (make-local wrapper rs)))
            (ensure-equalp (fields ls)
                           (fields struct)))))))
  

  (define-test "servant-wrapper invoke"
    (let* ((poa (handler-case 
                  (op:create_poa rootpoa "IFWRAP-TEST"
                                 (omg.org/features:the_poamanager rootpoa)
                                 '(:use-default-servant
                                   :user-id
                                   :transient))
                  (poa/adapteralreadyexists ()
                                            (op:find_poa rootpoa "IFWRAP-TEST" nil))))
           (servant (make-instance 'servant-wrapper
                      :orb orb
                      :poa poa)))
      (omg.org/features:set_servant poa servant)

      (let ((repository-proxy (make-remote servant *idef-repository*)))
        (op:describe (op:lookup repository-proxy "CORBA::StringDef"))
        (map nil #'op:name (op:contents repository-proxy :dk_all t))
        
        ;; check that it handles exceptions!

        ;; check updates..

      )
))

)