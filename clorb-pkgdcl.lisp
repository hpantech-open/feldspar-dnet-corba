(in-package :cl-user)

(defpackage "OMG.ORG/CORBA"
  (:nicknames :CORBA)
  (:use)
  (:export
   ORB_init ORB
   Request Object Proxy
   ;;request-result request-send request-invoke request-get-response
   funcall define-method
   ;; NamedValue
   Flags Identifier NamedValue
   ARG_IN ARG_OUT ARG_INOUT CTX_RESTRICT_SCOPE
   ;; Any
   Any any-value any-typecode
   ;; Exceptions
   exception systemexception userexception
   UNKNOWN BAD_PARAM NO_MEMORY IMP_LIMIT
   COMM_FAILURE INV_OBJREF NO_PERMISSION INTERNAL MARSHAL
   INITIALIZE NO_IMPLEMENT BAD_TYPECODE BAD_OPERATION
   NO_RESOURCES NO_RESPONSE PERSIST_STORE BAD_INV_ORDER
   TRANSIENT FREE_MEM INV_IDENT INV_FLAG INTF_REPOS
   BAD_CONTEXT OBJ_ADAPTER DATA_CONVERSION OBJECT_NOT_EXIST
   TRANSACTION_REQUIRED TRANSACTION_ROLLEDBACK INVALID_TRANSACTION
   ;; Type code constants
   tc_null tc_void tc_short tc_long tc_ushort tc_ulong
   tc_float tc_double tc_boolean tc_char
   tc_octet tc_any tc_typecode tc_principal tc_objref
   tc_struct tc_union tc_enum tc_string
   tc_sequence tc_array tc_alias tc_except
   tc_longlong tc_ulonglong tc_longdouble
   tc_wchar tc_wstring tc_fixed
   ;; types
   boolean char wchar octet string wstring short
   ushort long ulong longlong ulonglong float double
   fixed
   ;; non simple
   TCKind
   typecode typecode/bounds typecode/badkind union 
   struct environment
   ;; Interface repository types
   ParameterDescription))


(defpackage "OMG.ORG/FEATURES"
  (:nicknames :op)
  (:use)
  (:export
   GET_POA GET_OBJECT_ID
   ABSOLUTE_NAME ACTIVATE ACTIVATE_OBJECT ACTIVATE_OBJECT_WITH_ID
   ADD_INOUT_ARG ADD_IN_ARG ADD_NAMED_OUT_ARG ADD_OUT_ARG ARGUMENT ARGUMENTS
   ARG_MODES BASE_INTERFACES BIND BIND_CONTEXT BIND_NEW_CONTEXT BOUND CLEAR
   CONNECT_PULL_CONSUMER CONNECT_PULL_SUPPLIER CONNECT_PUSH_CONSUMER
   CONNECT_PUSH_SUPPLIER CONTAINING_REPOSITORY CONTENTS CONTENT_TYPE CONTEXTS
   CREATE_ARRAY CREATE_FIXED CREATE_MODULE CREATE_POA CREATE_REFERENCE
   CREATE_REFERENCE_WITH_ID CREATE_REQUEST CREATE_SEQUENCE CREATE_STRING
   CREATE_STRUCT CTX DEACTIVATE DEACTIVATE_OBJECT DEFAULT_FILTER DEFAULT_INDEX
   DEFINED_IN DEF_KIND DESCRIBE DESCRIBE_INTERFACE DESTROY DISCARD_REQUESTS
   DISCONNECT_PULL_CONSUMER DISCONNECT_PULL_SUPPLIER DISCONNECT_PUSH_CONSUMER
   DISCONNECT_PUSH_SUPPLIER DISCRIMINATOR_TYPE DISCRIMINATOR_TYPE_DEF
   ELEMENT_TYPE ELEMENT_TYPE_DEF EQUAL ETHEREALIZE EXCEPTIONS FIND_POA FOO
   FOR_CONSUMERS FOR_SUPPLIERS GET-STATE GET_PRIMITIVE GET_SERVANT
   GET_SERVANT_MANAGER GET_STATE GREET HOLD_REQUESTS ID ID_TO_REFERENCE
   ID_TO_SERVANT INCARNATE INVOKE IS_A KIND LENGTH LIST
   LIST_INITIAL_REFERENCES LOOKUP LOOKUP_ID LOOKUP_NAME MEMBERS MEMBER_COUNT
   MEMBER_LABEL MEMBER_NAME MEMBER_TYPE MODE NAME NEW_CHANNEL NEW_CONTEXT
   NEXT_N NEXT_ONE OBJECT_TO_STRING OBTAIN_PULL_CONSUMER OBTAIN_PULL_SUPPLIER
   OBTAIN_PUSH_CONSUMER OBTAIN_PUSH_SUPPLIER OPERATION ORIGINAL_TYPE_DEF
   PARAMS PERFORM_WORK POSTINVOKE PREINVOKE PRIMARY_INTERFACE PULL PUSH
   PUT_LONG PUT_STRING REBIND REBIND_CONTEXT REFERENCE_TO_ID
   REFERENCE_TO_SERVANT RESOLVE RESOLVE_INITIAL_REFERENCES RESULT RESULT_DEF
   RETURN_VALUE RUN SERVANT_TO_ID SERVANT_TO_REFERENCE SET_EXCEPTION
   SET_RESULT SET_RETURN_TYPE SET_SERVANT SET_SERVANT_MANAGER SHUTDOWN
   STRING_TO_OBJECT TARGET THE_ACTIVATOR THE_NAME THE_PARENT THE_POAMANAGER
   TRY_PULL TYPE TYPE_DEF UNBIND VERSION WORK_PENDING _CREATE_REQUEST
   _DEFAULT_POA _GET_ABSOLUTE_NAME _GET_ARGUMENT _GET_ARGUMENTS _GET_ARG_MODES
   _GET_BASE_INTERFACES _GET_BOUND _GET_CONTAINING_REPOSITORY _GET_CONTEXTS
   _GET_CTX _GET_DEFINED_IN _GET_DEF_KIND _GET_DISCRIMINATOR_TYPE_DEF
   _GET_ELEMENT_TYPE_DEF _GET_EXCEPTIONS _GET_ID _GET_INTERFACE _GET_KIND
   _GET_MEMBERS _GET_MODE _GET_NAME _GET_OPERATION _GET_ORIGINAL_TYPE_DEF
   _GET_PARAMS _GET_RESULT _GET_RESULT_DEF _GET_TARGET _GET_THE_ACTIVATOR
   _GET_THE_NAME _GET_THE_PARENT _GET_THE_POAMANAGER _GET_TYPE _GET_TYPE_DEF
   _GET_VERSION _HASH _INTERFACE _IS_A _IS_EQUIVALENT _IS_NIL _NON_EXISTENT
   _SET_ARGUMENT _SET_ARG_MODES _SET_BASE_INTERFACES _SET_BOUND _SET_CONTEXTS
   _SET_CTX _SET_DISCRIMINATOR_TYPE_DEF _SET_ELEMENT_TYPE_DEF _SET_EXCEPTIONS
   _SET_KIND _SET_MEMBERS _SET_MODE _SET_NAME _SET_ORIGINAL_TYPE_DEF
   _SET_PARAMS _SET_RESULT_DEF _SET_THE_ACTIVATOR _SET_TYPE_DEF _SET_VERSION
   _THIS))


(defpackage "OMG.ORG/ROOT"
  (:use))

(defpackage "OMG.ORG/PORTABLESERVER"
  (:nicknames :PortableServer)
  (:use)
  (:export ForwardRequest
           Servant 
           ServantManager ServantActivator 
           ServantLocator ServantLocator/cookie
           DynamicImplementation
           oid-to-string string-to-oid
           POAManager
           POAManager/AdapterInactive
           AdapterActivator
           POA 
           POA/AdapterAlreadyExists
           POA/AdapterInactive
           POA/AdapterNonExistent
           POA/InvalidPolicy
           POA/NoServant
           POA/ObjectAlreadyActive
           POA/ObjectNotActive
           POA/ServantAlreadyActive
           POA/ServantNotActive
           POA/WrongAdapter
           POA/WrongPolicy
           Current Current/NoContext))


(defpackage :clorb
  (:use COMMON-LISP #+cmu MOP #-(or sbcl cmu mcl) CLOS PortableServer)
  #+cmu
  (:shadowing-import-from MOP CLASS-NAME BUILT-IN-CLASS CLASS-OF FIND-CLASS)
  (:export struct-typecode struct-get make-struct 
           ;; Utilities
           invoke resolve rebind
           ;; Extension
           auto-servant define-servant)
  #+clisp
  (:import-from LISP 
                SOCKET-ACCEPT SOCKET-CONNECT SOCKET-SERVER SOCKET-SERVER-CLOSE
                SOCKET-SERVER-HOST SOCKET-SERVER-PORT SOCKET-SERVICE-PORT
                SOCKET-STREAM-HANDLE SOCKET-STREAM-HOST SOCKET-STREAM-LOCAL
                SOCKET-STREAM-PEER SOCKET-STREAM-PORT SOCKET-WAIT)
  (:import-from CORBA 
                ORB_init ORB request object
                define-method struct
                ;; Exceptions
                exception systemexception userexception
                ;; NamedValue
                ARG_IN ARG_OUT ARG_INOUT CTX_RESTRICT_SCOPE
                any any-value any-typecode))
