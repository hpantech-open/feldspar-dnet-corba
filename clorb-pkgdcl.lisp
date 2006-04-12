(in-package :cl-user)

(defpackage "OMG.ORG/CORBA"
  (:use)
  (:nicknames "CORBA")
  (:export
   "STRINGVALUE" "WSTRINGVALUE"

   "ABSTRACTBASE" "ABSTRACTINTERFACEDEF" "ABSTRACTINTERFACEDEF-PROXY"
   "ABSTRACTINTERFACEDEFSEQ" "ALIASDEF" "ALIASDEF-PROXY" "ALIASDEF/ORIGINAL_TYPE_DEF" "ANY"
   "ANY-TYPECODE" "ANY-VALUE" "ANYSEQ" "ARG_IN" "ARG_INOUT" "ARG_OUT" "ARRAYDEF"
   "ARRAYDEF-PROXY" "ARRAYDEF/ELEMENT_TYPE" "ARRAYDEF/ELEMENT_TYPE_DEF" "ARRAYDEF/LENGTH"
   "ATTRDESCRIPTIONSEQ" "ATTRIBUTEDEF" "ATTRIBUTEDEF-PROXY" "ATTRIBUTEDEF/MODE"
   "ATTRIBUTEDEF/TYPE" "ATTRIBUTEDEF/TYPE_DEF" "ATTRIBUTEDESCRIPTION" "ATTRIBUTEMODE"
   "BAD_CONTEXT" "BAD_INV_ORDER" "BAD_OPERATION" "BAD_PARAM" "BAD_POLICY" "BAD_POLICY_TYPE"
   "BAD_POLICY_VALUE" "BAD_TYPECODE" "BOOLEAN" "BOOLEANSEQ" "CHAR" "CHARSEQ" "COMM_FAILURE"
   "COMPLETION_STATUS" "CONSTANTDEF" "CONSTANTDEF-PROXY" "CONSTANTDEF/TYPE"
   "CONSTANTDEF/TYPE_DEF" "CONSTANTDEF/VALUE" "CONSTANTDESCRIPTION" "CONTAINED"
   "CONTAINED-PROXY" "CONTAINED/ABSOLUTE_NAME" "CONTAINED/CONTAINING_REPOSITORY"
   "CONTAINED/DEFINED_IN" "CONTAINED/DESCRIBE" "CONTAINED/DESCRIPTION" "CONTAINED/ID"
   "CONTAINED/MOVE" "CONTAINED/NAME" "CONTAINED/VERSION" "CONTAINEDSEQ" "CONTAINER"
   "CONTAINER-PROXY" "CONTAINER/CONTENTS" "CONTAINER/CREATE_ABSTRACT_INTERFACE"
   "CONTAINER/CREATE_ALIAS" "CONTAINER/CREATE_CONSTANT" "CONTAINER/CREATE_ENUM"
   "CONTAINER/CREATE_EXCEPTION" "CONTAINER/CREATE_INTERFACE"
   "CONTAINER/CREATE_LOCAL_INTERFACE" "CONTAINER/CREATE_MODULE" "CONTAINER/CREATE_NATIVE"
   "CONTAINER/CREATE_STRUCT" "CONTAINER/CREATE_UNION" "CONTAINER/CREATE_VALUE"
   "CONTAINER/CREATE_VALUE_BOX" "CONTAINER/DESCRIBE_CONTENTS" "CONTAINER/DESCRIPTION"
   "CONTAINER/DESCRIPTIONSEQ" "CONTAINER/LOOKUP" "CONTAINER/LOOKUP_NAME" "CONTEXTIDENTIFIER"
   "CONTEXTIDSEQ" "CTX_RESTRICT_SCOPE" "CURRENT" "DATA_CONVERSION" "DEFINE-METHOD"
   "DEFINITIONKIND" "DOUBLE" "DOUBLESEQ" "ENUMDEF" "ENUMDEF-PROXY" "ENUMDEF/MEMBERS"
   "ENUMMEMBERSEQ" "ENVIRONMENT" "EXCDESCRIPTIONSEQ" "EXCEPTION" "EXCEPTIONDEF"
   "EXCEPTIONDEF-PROXY" "EXCEPTIONDEF/MEMBERS" "EXCEPTIONDEF/TYPE" "EXCEPTIONDEFSEQ"
   "EXCEPTIONDESCRIPTION" "FIXED" "FIXEDDEF" "FIXEDDEF-PROXY" "FIXEDDEF/DIGITS"
   "FIXEDDEF/SCALE" "FLAGS" "FLOAT" "FLOATSEQ" "FREE_MEM" "FUNCALL" "IDENTIFIER" "IDL"
   "IDLTYPE" "IDLTYPE-PROXY" "IDLTYPE/TYPE" "IDLTYPESEQ" "IMP_LIMIT" "INITIALIZE"
   "INITIALIZER" "INITIALIZERSEQ" "INTERFACEDEF" "INTERFACEDEF-PROXY"
   "INTERFACEDEF/BASE_INTERFACES" "INTERFACEDEF/CREATE_ATTRIBUTE"
   "INTERFACEDEF/CREATE_OPERATION" "INTERFACEDEF/DESCRIBE_INTERFACE"
   "INTERFACEDEF/FULLINTERFACEDESCRIPTION" "INTERFACEDEF/IS_A" "INTERFACEDEFSEQ"
   "INTERFACEDESCRIPTION" "INTERNAL" "INTF_REPOS" "INVALID_TRANSACTION" "INV_FLAG" "INV_IDENT"
   "INV_OBJREF" "IROBJECT" "IROBJECT-PROXY" "IROBJECT/DEF_KIND" "IROBJECT/DESTROY"
   "LOCALINTERFACEDEF" "LOCALINTERFACEDEF-PROXY" "LOCALINTERFACEDEFSEQ" "LONG" "LONGDOUBLE"
   "LONGLONG" "LONGLONGSEQ" "LONGSEQ" "MARSHAL" "MODULEDEF" "MODULEDEF-PROXY"
   "MODULEDESCRIPTION" "NAMEDVALUE" "NATIVEDEF" "NATIVEDEF-PROXY" "NO_IMPLEMENT" "NO_MEMORY"
   "NO_PERMISSION" "NO_RESOURCES" "NO_RESPONSE" "OBJECT" "OBJECT_NOT_EXIST" "OBJ_ADAPTER" "OMGVMCID"
   "OCTET" "OCTETSEQ" "OPDESCRIPTIONSEQ" "OPERATIONDEF" "OPERATIONDEF-PROXY"
   "OPERATIONDEF/CONTEXTS" "OPERATIONDEF/EXCEPTIONS" "OPERATIONDEF/MODE" "OPERATIONDEF/PARAMS"
   "OPERATIONDEF/RESULT" "OPERATIONDEF/RESULT_DEF" "OPERATIONDESCRIPTION" "OPERATIONMODE"
   "ORB" "ORB/INVALIDNAME" "ORBID" "ORB_INIT" "PARAMETERDESCRIPTION" "PARAMETERMODE"
   "PARDESCRIPTIONSEQ" "PERSIST_STORE" "POLICY" "POLICY-PROXY" "POLICYERROR" "POLICYERRORCODE"
   "POLICYLIST" "POLICYTYPE" "PRIMITIVEDEF" "PRIMITIVEDEF-PROXY" "PRIMITIVEDEF/KIND"
   "PRIMITIVEKIND" "PRIVATE_MEMBER" "PROXY" "PUBLIC_MEMBER" "REPOSITORY" "REPOSITORY-PROXY"
   "REPOSITORY/CREATE_ARRAY" "REPOSITORY/CREATE_FIXED" "REPOSITORY/CREATE_SEQUENCE"
   "REPOSITORY/CREATE_STRING" "REPOSITORY/CREATE_WSTRING" "REPOSITORY/GET_CANONICAL_TYPECODE"
   "REPOSITORY/GET_PRIMITIVE" "REPOSITORY/LOOKUP_ID" "REPOSITORYID" "REPOSITORYIDSEQ"
   "REQUEST" "SCOPEDNAME" "SECCONSTRUCTION" "SECURITY" "SEQUENCEDEF" "SEQUENCEDEF-PROXY"
   "SEQUENCEDEF/BOUND" "SEQUENCEDEF/ELEMENT_TYPE" "SEQUENCEDEF/ELEMENT_TYPE_DEF"
   "SERVERREQUEST" "SERVICEDETAIL" "SERVICEDETAILTYPE" "SERVICEINFORMATION" "SERVICEOPTION"
   "SERVICETYPE" "SHORT" "SHORTSEQ" "STRING" "STRINGDEF" "STRINGDEF-PROXY" "STRINGDEF/BOUND"
   "STRINGSEQ" "STRUCT" "STRUCTDEF" "STRUCTDEF-PROXY" "STRUCTDEF/MEMBERS" "STRUCTMEMBER"
   "STRUCTMEMBERSEQ" "SYSTEMEXCEPTION" "TCKIND" "TC_ALIAS" "TC_ANY" "TC_ARRAY" "TC_BOOLEAN"
   "TC_CHAR" "TC_COMPLETION_STATUS" "TC_DOUBLE" "TC_ENUM" "TC_EXCEPT" "TC_FIXED" "TC_FLOAT"
   "TC_LONG" "TC_LONGDOUBLE" "TC_LONGLONG" "TC_NULL" "TC_OBJECT" "TC_OCTET" "TC_PRINCIPAL"
   "TC_SEQUENCE" "TC_SHORT" "TC_STRING" "TC_STRUCT" "TC_TYPECODE" "TC_ULONG" "TC_ULONGLONG"
   "TC_UNION" "TC_USHORT" "TC_VALUEBASE" "TC_VOID" "TC_WCHAR" "TC_WSTRING"
   "TRANSACTION_REQUIRED" "TRANSACTION_ROLLEDBACK" "TRANSIENT" "TYPECODE" "TYPECODE-PROXY"
   "TYPECODE/BADKIND" "TYPECODE/BOUNDS" "TYPECODEFACTORY" "TYPEDEFDEF" "TYPEDEFDEF-PROXY"
   "TYPEDESCRIPTION" "ULONG" "ULONGLONG" "ULONGLONGSEQ" "ULONGSEQ" "UNION" "UNIONDEF"
   "UNIONDEF-PROXY" "UNIONDEF/DISCRIMINATOR_TYPE" "UNIONDEF/DISCRIMINATOR_TYPE_DEF"
   "UNIONDEF/MEMBERS" "UNIONMEMBER" "UNIONMEMBERSEQ" "UNKNOWN" "UNSUPPORTED_POLICY"
   "UNSUPPORTED_POLICY_VALUE" "USEREXCEPTION" "USHORT" "USHORTSEQ" "VALUEBASE" "VALUEBOXDEF"
   "VALUEBOXDEF-PROXY" "VALUEBOXDEF/ORIGINAL_TYPE_DEF" "VALUEDEF" "VALUEDEF-PROXY"
   "VALUEDEF/ABSTRACT_BASE_VALUES" "VALUEDEF/BASE_VALUE" "VALUEDEF/CREATE_ATTRIBUTE"
   "VALUEDEF/CREATE_OPERATION" "VALUEDEF/CREATE_VALUE_MEMBER" "VALUEDEF/DESCRIBE_VALUE"
   "VALUEDEF/FULLVALUEDESCRIPTION" "VALUEDEF/INITIALIZERS" "VALUEDEF/IS_A"
   "VALUEDEF/IS_ABSTRACT" "VALUEDEF/IS_CUSTOM" "VALUEDEF/IS_TRUNCATABLE"
   "VALUEDEF/SUPPORTED_INTERFACES" "VALUEDEFSEQ" "VALUEDESCRIPTION" "VALUEMEMBER"
   "VALUEMEMBERDEF" "VALUEMEMBERDEF-PROXY" "VALUEMEMBERDEF/ACCESS" "VALUEMEMBERDEF/TYPE"
   "VALUEMEMBERDEF/TYPE_DEF" "VALUEMEMBERSEQ" "VALUEMODIFIER" "VERSIONSPEC" "VISIBILITY"
   "VM_ABSTRACT" "VM_CUSTOM" "VM_NONE" "VM_TRUNCATABLE" "WCHAR" "WCHARSEQ" "WSTRING"
   "WSTRINGDEF" "WSTRINGDEF-PROXY" "WSTRINGDEF/BOUND" "WSTRINGSEQ"))

(defpackage "OMG.ORG/IOP"
  (:use)
  (:nicknames "IOP")
  (:export
   "ENCODING" "ENCODINGFORMAT" "ENCODING_CDR_ENCAPS" "TAGGEDCOMPONENTSEQ"
   "BI_DIR_IIOP" "CHAINBYPASSCHECK" "CHAINBYPASSINFO" "CODEC"
   "CODEC/FORMATMISMATCH" "CODEC/INVALIDTYPEFORENCODING" "CODEC/TYPEMISMATCH"
   "CODECFACTORY" "CODECFACTORY/UNKNOWNENCODING" "CODESETS" "COMPONENTID"
   "ENCODING" "ENCODINGFORMAT" "ENCODING_CDR_ENCAPS" "FORWARDED_IDENTITY"
   "INVOCATION_POLICIES" "IOR" "LOGICALTHREADID" "MULTIPLECOMPONENTPROFILE"
   "PROFILEID" "SENDINGCONTEXTRUNTIME" "SERVICECONTEXT" "SERVICECONTEXTLIST"
   "SERVICEID" "TAGGEDCOMPONENT" "TAGGEDPROFILE" "TAG_ALTERNATE_IIOP_ADDRESS"
   "TAG_ASSOCIATION_OPTIONS" "TAG_CODE_SETS" "TAG_COMPLETE_OBJECT_KEY"
   "TAG_CSI_ECMA_HYBRID_SEC_MECH" "TAG_CSI_ECMA_PUBLIC_SEC_MECH"
   "TAG_CSI_ECMA_SECRET_SEC_MECH" "TAG_DCE_BINDING_NAME" "TAG_DCE_NO_PIPES"
   "TAG_DCE_SEC_MECH" "TAG_DCE_STRING_BINDING" "TAG_ENDPOINT_ID_POSITION"
   "TAG_FT_GROUP" "TAG_GENERIC_SEC_MECH" "TAG_INTERNET_IOP" "TAG_JAVA_CODEBASE"
   "TAG_KERBEROSV5_SEC_MECH" "TAG_LOCATION_POLICY" "TAG_MULTIPLE_COMPONENTS"
   "TAG_ORB_TYPE" "TAG_POLICIES" "TAG_SEC_NAME" "TAG_SPKM_1_SEC_MECH"
   "TAG_SPKM_2_SEC_MECH" "TAG_SSL_SEC_TRANS" "TRANSACTIONSERVICE"
   "UNKNOWNEXCEPTIONINFO"))

(defpackage "OMG.ORG/GIOP"
  (:use)
  (:nicknames "GIOP")
  (:export
   "CANCELREQUESTHEADER" "LOCATEREPLYHEADER" "LOCATEREQUESTHEADER"
   "LOCATESTATUSTYPE" "MESSAGEHEADER_1_0" "MESSAGEHEADER_1_1" "MSGTYPE_1_0"
   "MSGTYPE_1_1" "PRINCIPAL" "REPLYHEADER" "REPLYSTATUSTYPE" "REQUESTHEADER_1_0"
   "REQUESTHEADER_1_1" "VERSION"))

(defpackage "OMG.ORG/IIOP"
  (:use)
  (:nicknames "IIOP")
  (:export
   "PROFILEBODY_1_0" "PROFILEBODY_1_1" "VERSION"))

(defpackage "OMG.ORG/FEATURES"
  (:use)
  (:nicknames "OP")
  (:export
   "NARROW" "_NARROW"
   "ABSOLUTE_NAME" "ABSTRACT_BASE_VALUES" "ACCESS" "ACTIVATE" "ACTIVATE_OBJECT" "ACTIVATE_OBJECT_WITH_ID"
   "ADD_CONTAINED" "ADD_INOUT_ARG" "ADD_IN_ARG" "ADD_NAMED_INOUT_ARG" "ADD_NAMED_IN_ARG"
   "ADD_NAMED_OUT_ARG" "ADD_OUT_ARG" "ARGUMENT" "ARGUMENTS" "ARG_MODES" "ATTRIBUTES" "BASE_INTERFACES"
   "BASE_VALUE" "BIND" "BINDING_NAME" "BINDING_TYPE" "BIND_CONTEXT" "BIND_NEW_CONTEXT" "BOUND"
   "BYTE_ORDER" "CLEAR" "CODEC_FACTORY" "COMPLETED" "COMPONENT_DATA" "CONCRETE_BASE_TYPE"
   "CONNECT_PULL_CONSUMER" "CONNECT_PULL_SUPPLIER" "CONNECT_PUSH_CONSUMER" "CONNECT_PUSH_SUPPLIER"
   "CONTAINED_OBJECT" "CONTAINING_REPOSITORY" "CONTENTS" "CONTENT_TYPE" "CONTEXTS" "CONTEXT_DATA"
   "CONTEXT_ID" "COPY" "CREATE_ABSTRACT_INTERFACE" "CREATE_ABSTRACT_INTERFACE_TC" "CREATE_ALIAS"
   "CREATE_ALIAS_TC" "CREATE_ARRAY" "CREATE_ARRAY_TC" "CREATE_ATTRIBUTE" "CREATE_CONSTANT" "CREATE_ENUM"
   "CREATE_ENUM_TC" "CREATE_EXCEPTION" "CREATE_EXCEPTION_TC" "CREATE_FIXED" "CREATE_FIXED_TC"
   "CREATE_ID_ASSIGNMENT_POLICY" "CREATE_ID_UNIQUENESS_POLICY" "CREATE_IMPLICIT_ACTIVATION_POLICY"
   "CREATE_INTERFACE" "CREATE_INTERFACE_TC" "CREATE_LIFESPAN_POLICY" "CREATE_LOCAL_INTERFACE"
   "CREATE_LOCAL_INTERFACE_TC" "CREATE_MODULE" "CREATE_NATIVE" "CREATE_NATIVE_TC" "CREATE_OPERATION"
   "CREATE_OPERATION_LIST" "CREATE_POA" "CREATE_POLICY" "CREATE_RECURSIVE_TC" "CREATE_REFERENCE"
   "CREATE_REFERENCE_WITH_ID" "CREATE_REQUEST" "CREATE_REQUEST_PROCESSING_POLICY" "CREATE_SEQUENCE"
   "CREATE_SEQUENCE_TC" "CREATE_SERVANT_RETENTION_POLICY" "CREATE_STRING" "CREATE_STRING_TC"
   "CREATE_STRUCT" "CREATE_STRUCT_TC" "CREATE_THREAD_POLICY" "CREATE_UNION" "CREATE_UNION_TC"
   "CREATE_VALUE" "CREATE_VALUE_BOX" "CREATE_VALUE_BOX_TC" "CREATE_VALUE_MEMBER" "CREATE_VALUE_TC"
   "CREATE_WSTRING" "CREATE_WSTRING_TC" "CTX" "CXT" "DEACTIVATE" "DEACTIVATE_OBJECT" "DEFAULT"
   "DEFAULT_FILTER" "DEFAULT_INDEX" "DEFINED_IN" "DEF_KIND" "DESCRIBE" "DESCRIBE_CONTENTS"
   "DESCRIBE_INTERFACE" "DESCRIBE_VALUE" "DESTROY" "DIGITS" "DISCARD_REQUESTS" "DISCONNECT_PULL_CONSUMER"
   "DISCONNECT_PULL_SUPPLIER" "DISCONNECT_PUSH_CONSUMER" "DISCONNECT_PUSH_SUPPLIER" "DISCRIMINATOR_TYPE"
   "DISCRIMINATOR_TYPE_DEF" "ELEMENT_TYPE" "ELEMENT_TYPE_DEF" "EQUAL" "ETHEREALIZE" "EXCEPTIONS"
   "FIND_POA" "FIXED_DIGITS" "FIXED_SCALE" "FOO" "FORWARD_REFERENCE" "FOR_CONSUMERS" "FOR_SUPPLIERS"
   "GET-STATE" "GET_ANONYMOUS_TYPES" "GET_CANONICAL_TYPECODE" "GET_OBJECT_ID" "GET_POA" "GET_PRIMITIVE"
   "GET_RESPONSE" "GET_SERVANT" "GET_SERVANT_MANAGER" "GET_STATE" "GIOP_VERSION" "GREET" "HOLD_REQUESTS"
   "ID" "ID_TO_REFERENCE" "ID_TO_SERVANT" "INCARNATE" "INDEX" "INITIALIZERS" "INVOKE" "IS_A"
   "IS_ABSTRACT" "IS_CUSTOM" "IS_TRUNCATABLE" "KIND" "LABEL" "LENGTH" "LIST" "LIST_INITIAL_REFERENCES"
   "LOCATE_ID" "LOCATE_NAME" "LOCATE_STATUS" "LOOKUP" "LOOKUP_ID" "LOOKUP_NAME" "MAGIC" "MAJOR" "MEMBERS"
   "MEMBER_COUNT" "MEMBER_LABEL" "MEMBER_NAME" "MEMBER_TYPE" "MEMBER_VISIBILITY" "MESSAGE_SIZE"
   "MESSAGE_TYPE" "MINOR" "MODE" "MOVE" "NAME" "NEW_CHANNEL" "NEW_CONTEXT" "NEXT_N" "NEXT_ONE"
   "OBJECT_KEY" "OBJECT_TO_STRING" "OBTAIN_PULL_CONSUMER" "OBTAIN_PULL_SUPPLIER" "OBTAIN_PUSH_CONSUMER"
   "OBTAIN_PUSH_SUPPLIER" "OPERATION" "OPERATIONS" "ORB_ID" "ORIGINAL_TYPE_DEF" "PARAMETERS" "PARAMS"
   "PERFORM_WORK" "POLICY_TYPE" "POLL_RESPONSE" "POSTINVOKE" "POST_INIT" "PREINVOKE" "PRE_INIT"
   "PRIMARY_INTERFACE" "PROFILES" "PROFILE_DATA" "PULL" "PUSH" "PUT_LONG" "PUT_STRING" "REASON" "REBIND"
   "REBIND_CONTEXT" "REFERENCE_TO_ID" "REFERENCE_TO_SERVANT" "REGISTER_INITIAL_REFERENCE"
   "REMOVE_CONTAINED" "REPLY_STATUS" "REQUESTING_PRINCIPAL" "REQUEST_ID" "RESOLVE"
   "RESOLVE_INITIAL_REFERENCES" "RESOLVE_STR" "RESPONSE_EXPECTED" "REST_OF_NAME" "RESULT" "RESULT_DEF"
   "RETURN_VALUE" "RUN" "SCALE" "SEND_DEFERRED" "SEND_ONEWAY" "SERVANT_TO_ID" "SERVANT_TO_REFERENCE"
   "SERVICE_CONTEXT" "SERVICE_DETAIL" "SERVICE_DETAILS" "SERVICE_DETAIL_TYPE" "SERVICE_OPTIONS"
   "SET_EXCEPTION" "SET_RESULT" "SET_RETURN_TYPE" "SET_SERVANT" "SET_SERVANT_MANAGER" "SHUTDOWN"
   "STRING_TO_OBJECT" "SUPPORTED_INTERFACES" "TAG" "TARGET" "THE_ACTIVATOR" "THE_CHILDREN" "THE_NAME"
   "THE_PARENT" "THE_POAMANAGER" "TO_NAME" "TO_STRING" "TO_URL" "TRY_PULL" "TYPE" "TYPE_DEF" "TYPE_ID"
   "TYPE_MODIFIER" "UNBIND" "UNKNOWN_ADAPTER" "VALUE" "VERSION" "WHY" "WORK_PENDING" "_CREATE_REQUEST"
   "_DEFAULT_POA" "_GET_ABSOLUTE_NAME" "_GET_ARGUMENT" "_GET_ARGUMENTS" "_GET_ARG_MODES"
   "_GET_BASE_INTERFACES" "_GET_BOUND" "_GET_CONTAINING_REPOSITORY" "_GET_CONTEXTS" "_GET_CTX"
   "_GET_DEFINED_IN" "_GET_DEF_KIND" "_GET_DISCRIMINATOR_TYPE_DEF" "_GET_ELEMENT_TYPE_DEF"
   "_GET_EXCEPTIONS" "_GET_ID" "_GET_INTERFACE" "_GET_KIND" "_GET_MEMBERS" "_GET_MODE" "_GET_NAME"
   "_GET_OPERATION" "_GET_ORIGINAL_TYPE_DEF" "_GET_PARAMS" "_GET_RESULT" "_GET_RESULT_DEF" "_GET_TARGET"
   "_GET_THE_ACTIVATOR" "_GET_THE_NAME" "_GET_THE_PARENT" "_GET_THE_POAMANAGER" "_GET_TYPE"
   "_GET_TYPE_DEF" "_GET_VALUE" "_GET_VERSION" "_HASH" "_INTERFACE" "_IS_A" "_IS_EQUIVALENT" "_IS_NIL"
   "_NON_EXISTENT" "_OBJECT_ID" "_ORB" "_POA" "_SET_ARGUMENT" "_SET_ARG_MODES" "_SET_BASE_INTERFACES"
   "_SET_BOUND" "_SET_CONTEXTS" "_SET_CTX" "_SET_DISCRIMINATOR_TYPE_DEF" "_SET_ELEMENT_TYPE_DEF"
   "_SET_EXCEPTIONS" "_SET_KIND" "_SET_MEMBERS" "_SET_MODE" "_SET_NAME" "_SET_ORIGINAL_TYPE_DEF"
   "_SET_PARAMS" "_SET_RESULT_DEF" "_SET_THE_ACTIVATOR" "_SET_TYPE_DEF" "_SET_VALUE" "_SET_VERSION"
   "_THIS"))


(defpackage "OMG.ORG/ROOT"
  (:use))

(defpackage "OMG.ORG/PORTABLESERVER"
  (:use)
  (:nicknames "PORTABLESERVER")
  (:export
   "ADAPTERACTIVATOR" "CURRENT" "CURRENT/NOCONTEXT" "DYNAMICIMPLEMENTATION" "FORWARDREQUEST"
   "IDASSIGNMENTPOLICY" "IDASSIGNMENTPOLICY-PROXY" "IDASSIGNMENTPOLICY-SERVANT"
   "IDASSIGNMENTPOLICYVALUE" "IDUNIQUENESSPOLICY" "IDUNIQUENESSPOLICY-PROXY"
   "IDUNIQUENESSPOLICY-SERVANT" "IDUNIQUENESSPOLICYVALUE" "ID_ASSIGNMENT_POLICY_ID"
   "ID_UNIQUENESS_POLICY_ID" "IMPLICITACTIVATIONPOLICY" "IMPLICITACTIVATIONPOLICY-PROXY"
   "IMPLICITACTIVATIONPOLICY-SERVANT" "IMPLICITACTIVATIONPOLICYVALUE"
   "IMPLICIT_ACTIVATION_POLICY_ID" "LIFESPANPOLICY" "LIFESPANPOLICY-PROXY"
   "LIFESPANPOLICY-SERVANT" "LIFESPANPOLICYVALUE" "LIFESPAN_POLICY_ID" "OBJECTID"
   "OID-TO-STRING" "POA" "POA/ADAPTERALREADYEXISTS" "POA/ADAPTERINACTIVE"
   "POA/ADAPTERNONEXISTENT" "POA/INVALIDPOLICY" "POA/NOSERVANT" "POA/OBJECTALREADYACTIVE"
   "POA/OBJECTNOTACTIVE" "POA/SERVANTALREADYACTIVE" "POA/SERVANTNOTACTIVE" "POA/WRONGADAPTER"
   "POA/WRONGPOLICY" "POALIST" "POAMANAGER" "POAMANAGER-PROXY" "POAMANAGER-SERVANT"
   "POAMANAGER/ADAPTERINACTIVE" "POAMANAGER/STATE" "REQUESTPROCESSINGPOLICY"
   "REQUESTPROCESSINGPOLICY-PROXY" "REQUESTPROCESSINGPOLICY-SERVANT"
   "REQUESTPROCESSINGPOLICYVALUE" "REQUEST_PROCESSING_POLICY_ID" "SERVANT" "SERVANTACTIVATOR"
   "SERVANTLOCATOR" "SERVANTLOCATOR/COOKIE" "SERVANTMANAGER" "SERVANTRETENTIONPOLICY"
   "SERVANTRETENTIONPOLICY-PROXY" "SERVANTRETENTIONPOLICY-SERVANT"
   "SERVANTRETENTIONPOLICYVALUE" "SERVANT_RETENTION_POLICY_ID" "STRING-TO-OID" "THREADPOLICY"
   "THREADPOLICY-PROXY" "THREADPOLICY-SERVANT" "THREADPOLICYVALUE" "THREAD_POLICY_ID"))

(defpackage "OMG.ORG/DYNAMIC"
  (:use)
  (:nicknames "DYNAMIC")
  (:export
   "CONTEXTLIST" "EXCEPTIONLIST" "PARAMETER" "PARAMETERLIST" "REQUESTCONTEXT"))

(defpackage "OMG.ORG/PORTABLEINTERCEPTOR"
  (:use)
  (:nicknames "PORTABLEINTERCEPTOR")
  (:export
   "CLIENTREQUESTINFO" "CLIENTREQUESTINTERCEPTOR" "CONTEXTLIST" "CURRENT" "EXCEPTIONLIST"
   "FORWARDREQUEST" "INTERCEPTOR" "INVALIDSLOT" "IORINFO" "IORINTERCEPTOR" "LOCATION_FORWARD"
   "ORBINITIALIZER" "ORBINITINFO" "ORBINITINFO/DUPLICATENAME" "ORBINITINFO/INVALIDNAME"
   "ORBINITINFO/OBJECTID" "PARAMETER" "PARAMETERLIST" "POLICYFACTORY"
   "REGISTER_ORB_INITIALIZER" "REPLYSTATUS" "REQUESTCONTEXT" "REQUESTINFO" "SERVERREQUESTINFO"
   "SERVERREQUESTINTERCEPTOR" "SLOTID" "SUCCESSFUL" "SYSTEM_EXCEPTION" "TRANSPORT_RETRY"
   "USER_EXCEPTION"))


;;;; Implementation Packages

(defpackage "NET.CDDR.CLORB.INTERNALS"
  (:use "COMMON-LISP")
  (:export idl-compiler load-repository *default-idl-compiler*
           *default-include-directories*
           ;; idlcpp
           using-cpp-stream read-cpp-line
           idl-prefix idl-source-position idl-repositoryid-pragmas
           ;; idef
           idef-read 
           ;; sysdep
           shell-to-string-or-stream external-namestring))

(defpackage "NET.CDDR.CLORB"
  (:nicknames "CLORB")
  (:use "COMMON-LISP" "NET.CDDR.CLORB.INTERNALS" 
        "NET.CDDR.REDPAS" "NET.CDDR.LUNA"
        #+cmu "MOP")
  #+cmu
  (:shadowing-import-from "MOP"
              "CLASS-NAME" "BUILT-IN-CLASS" "CLASS-OF" "FIND-CLASS")
  (:export "STRUCT-GET"
           ;; Utilities
           "INVOKE" "RESOLVE" "REBIND" "PATHNAME-URL"
           ;; Useful internals
           "LOAD-IR" "*RUNNING-ORB*" "ROOT-POA"
           "*HOST*" )
  (:import-from "OMG.ORG/PORTABLESERVER"
                "POA" "STRING-TO-OID" "OID-TO-STRING")
  (:import-from "OMG.ORG/CORBA"
                "ORB" "OBJECT"
                "DEFINE-METHOD" "STRUCT"
                ;; Exceptions
                "EXCEPTION" "SYSTEMEXCEPTION" "USEREXCEPTION"
                ;; NamedValue
                "ARG_IN" "ARG_OUT" "ARG_INOUT" "CTX_RESTRICT_SCOPE"
                "ANY" "ANY-VALUE" "ANY-TYPECODE"))

(defpackage "NET.CDDR.CLORB.PERSISTENT-NAMING"
  (:nicknames "PERSISTENT-NAMING")
  (:use "COMMON-LISP")
  (:import-from "CORBA" "DEFINE-METHOD")
  (:export "*NAMING-IOR-FILE*" "*NAMING-BASE-PATH*" "*NAMING-POA*"
           "SETUP-PNS" "SETUP-NAMING-POA"))

(defpackage "NET.CDDR.CLORB.IDLCOMP"
  (:nicknames "CLORB.IDLCOMP")
  (:use "COMMON-LISP" "NET.CDDR.CLORB" "NET.CDDR.CLORB.INTERNALS"))
