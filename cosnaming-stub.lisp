(in-package :clorb)

(defpackage "COSNAMING" (:use)
  (:export
   "BINDING"
   "BINDINGITERATOR" "BINDINGITERATOR-PROXY" "BINDINGITERATOR-SERVANT"
   "BINDINGLIST" "BINDINGTYPE" "ISTRING" "NAME" "NAMECOMPONENT"
   "NAMINGCONTEXT" "NAMINGCONTEXT-PROXY" "NAMINGCONTEXT-SERVANT"
   "NAMINGCONTEXT/ALREADYBOUND"
   "NAMINGCONTEXT/CANNOTPROCEED" "NAMINGCONTEXT/INVALIDNAME"
   "NAMINGCONTEXT/NOTEMPTY" "NAMINGCONTEXT/NOTFOUND"
   "NAMINGCONTEXT/NOTFOUNDREASON"))



(defclass COSNAMING:NAMINGCONTEXT (CORBA:Object) NIL)

(defclass COSNAMING:BINDINGITERATOR (CORBA:Object) NIL)

(define-user-exception COSNAMING:NAMINGCONTEXT/NOTEMPTY
    :ID "IDL:omg.org/CosNaming/NamingContext/NotEmpty:1.0")

(define-user-exception COSNAMING:NAMINGCONTEXT/ALREADYBOUND
    :ID "IDL:omg.org/CosNaming/NamingContext/AlreadyBound:1.0")

(define-user-exception COSNAMING:NAMINGCONTEXT/INVALIDNAME
    :ID "IDL:omg.org/CosNaming/NamingContext/InvalidName:1.0")

(define-user-exception COSNAMING:NAMINGCONTEXT/CANNOTPROCEED
    :ID "IDL:omg.org/CosNaming/NamingContext/CannotProceed:1.0"
    :SLOTS ((CXT :INITARG :CXT)
            (REST_OF_NAME :INITARG :REST_OF_NAME)))

(define-user-exception COSNAMING:NAMINGCONTEXT/NOTFOUND
    :ID "IDL:omg.org/CosNaming/NamingContext/NotFound:1.0"
    :SLOTS ((WHY :INITARG :WHY)
            (REST_OF_NAME :INITARG :REST_OF_NAME)))

(deftype COSNAMING:NAMINGCONTEXT/NOTFOUNDREASON ()
  '(MEMBER :MISSING_NODE :NOT_CONTEXT :NOT_OBJECT))

(deftype COSNAMING:BINDINGLIST NIL 'SEQUENCE)

(define-corba-struct COSNAMING:BINDING
    :ID "IDL:omg.org/CosNaming/Binding:1.0"
    :MEMBERS ((BINDING_NAME NIL)
              (BINDING_TYPE NIL)))

(deftype COSNAMING:BINDINGTYPE NIL
  '(MEMBER :NOBJECT :NCONTEXT))

(deftype COSNAMING:NAME NIL 'SEQUENCE)

(define-corba-struct COSNAMING:NAMECOMPONENT
    :ID "IDL:omg.org/CosNaming/NameComponent:1.0"
    :MEMBERS ((ID "")
              (KIND "")))

(deftype COSNAMING:ISTRING NIL 'OMG.ORG/CORBA:STRING)

 
(defclass COSNAMING:BINDINGITERATOR-PROXY
    (COSNAMING:BINDINGITERATOR OMG.ORG/CORBA:PROXY)
  NIL)

(clorb::register-proxy-class "IDL:omg.org/CosNaming/BindingIterator:1.0"
    'COSNAMING:BINDINGITERATOR-PROXY)

(defmethod OMG.ORG/FEATURES:DESTROY
    ((OBJ COSNAMING:BINDINGITERATOR-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "destroy" ARGS) )

(defmethod OMG.ORG/FEATURES:NEXT_N
    ((OBJ COSNAMING:BINDINGITERATOR-PROXY) &REST ARGS)
    (APPLY 'CLORB:INVOKE OBJ "next_n" ARGS))

(defmethod OMG.ORG/FEATURES:NEXT_ONE
    ((OBJ COSNAMING:BINDINGITERATOR-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "next_one" ARGS))


(defclass COSNAMING:NAMINGCONTEXT-PROXY
    (COSNAMING:NAMINGCONTEXT OMG.ORG/CORBA:PROXY) NIL)

(clorb::register-proxy-class "IDL:omg.org/CosNaming/NamingContext:1.0"
                      'COSNAMING:NAMINGCONTEXT-PROXY)

(defmethod OMG.ORG/FEATURES:LIST
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "list" ARGS))

(defmethod OMG.ORG/FEATURES:DESTROY
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "destroy" ARGS))

(defmethod OMG.ORG/FEATURES:BIND_NEW_CONTEXT
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "bind_new_context" ARGS))

(defmethod OMG.ORG/FEATURES:NEW_CONTEXT
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "new_context" ARGS))

(defmethod OMG.ORG/FEATURES:UNBIND
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "unbind" ARGS))

(defmethod OMG.ORG/FEATURES:RESOLVE
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "resolve" ARGS))

(defmethod OMG.ORG/FEATURES:REBIND_CONTEXT
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "rebind_context" ARGS))

(defmethod OMG.ORG/FEATURES:BIND_CONTEXT
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "bind_context" ARGS))

(defmethod OMG.ORG/FEATURES:REBIND
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "rebind" ARGS))

(defmethod OMG.ORG/FEATURES:BIND
    ((OBJ COSNAMING:NAMINGCONTEXT-PROXY) &REST ARGS)
  (APPLY 'CLORB:INVOKE OBJ "bind" ARGS))

