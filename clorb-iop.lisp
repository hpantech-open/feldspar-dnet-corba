
(in-package :clorb)

(defconstant iop:unknownexceptioninfo (quote 9))

(defconstant iop:forwarded_identity (quote 8))

(defconstant iop:invocation_policies (quote 7))

(defconstant iop:sendingcontextruntime (quote 6))

(defconstant iop:bi_dir_iiop (quote 5))

(defconstant iop:logicalthreadid (quote 4))

(defconstant iop:chainbypassinfo (quote 3))

(defconstant iop:chainbypasscheck (quote 2))

(defconstant iop:codesets (quote 1))

(defconstant iop:transactionservice (quote 0))

(DEFINE-ALIAS IOP:SERVICECONTEXTLIST
 :id "IDL:omg.org/IOP/ServiceContextList:1.0"
 :name "ServiceContextList"
 :type SEQUENCE
 :typecode (create-sequence-tc 0 (SYMBOL-TYPECODE 'IOP:SERVICECONTEXT)))

(DEFINE-STRUCT IOP:SERVICECONTEXT
 :id "IDL:omg.org/IOP/ServiceContext:1.0"
 :name "ServiceContext"
 :members (("context_id" (SYMBOL-TYPECODE 'IOP:SERVICEID) CONTEXT_ID)
           ("context_data" (create-sequence-tc 0 CORBA:TC_OCTET)
            CONTEXT_DATA))
 :read ((BUFFER)
        (IOP:SERVICECONTEXT
          :context_id (UNMARSHAL-ULONG BUFFER)
          :context_data (UNMARSHAL-OSEQUENCE BUFFER)))
 :write ((OBJ BUFFER)
         (MARSHAL-ULONG (op:CONTEXT_ID OBJ) BUFFER)
         (MARSHAL-OSEQUENCE (op:CONTEXT_DATA OBJ) BUFFER)))

(DEFINE-ALIAS IOP:SERVICEID
 :id "IDL:omg.org/IOP/ServiceId:1.0"
 :name "ServiceId"
 :type CORBA:ULONG
 :typecode CORBA:TC_ULONG)

(defconstant iop:tag_dce_sec_mech (quote 103))

(defconstant iop:tag_dce_no_pipes (quote 102))

(defconstant iop:tag_dce_binding_name (quote 101))

(defconstant iop:tag_dce_string_binding (quote 100))

(defconstant iop:tag_location_policy (quote 12))

(defconstant iop:tag_endpoint_id_position (quote 6))

(defconstant iop:tag_complete_object_key (quote 5))

(defconstant iop:tag_java_codebase (quote 25))

(defconstant iop:tag_generic_sec_mech (quote 22))

(defconstant iop:tag_csi_ecma_public_sec_mech (quote 21))

(defconstant iop:tag_ssl_sec_trans (quote 20))

(defconstant iop:tag_csi_ecma_hybrid_sec_mech (quote 19))

(defconstant iop:tag_csi_ecma_secret_sec_mech (quote 18))

(defconstant iop:tag_kerberosv5_sec_mech (quote 17))

(defconstant iop:tag_spkm_2_sec_mech (quote 16))

(defconstant iop:tag_spkm_1_sec_mech (quote 15))

(defconstant iop:tag_sec_name (quote 14))

(defconstant iop:tag_association_options (quote 13))

(defconstant iop:tag_alternate_iiop_address (quote 3))

(defconstant iop:tag_policies (quote 2))

(defconstant iop:tag_code_sets (quote 1))

(defconstant iop:tag_orb_type (quote 0))

(DEFINE-ALIAS IOP:MULTIPLECOMPONENTPROFILE
 :id "IDL:omg.org/IOP/MultipleComponentProfile:1.0"
 :name "MultipleComponentProfile"
 :type SEQUENCE
 :typecode (create-sequence-tc 0 (SYMBOL-TYPECODE 'IOP:TAGGEDCOMPONENT)))

(DEFINE-STRUCT IOP:TAGGEDCOMPONENT
 :ID "IDL:omg.org/IOP/TaggedComponent:1.0"
 :name "TaggedComponent"
 :members (("tag" (SYMBOL-TYPECODE 'IOP:COMPONENTID))
           ("component_data" (create-sequence-tc 0 OMG.ORG/CORBA:TC_OCTET))))

(DEFINE-ALIAS IOP:COMPONENTID
 :id "IDL:omg.org/IOP/ComponentId:1.0"
 :name "ComponentId"
 :type OMG.ORG/CORBA:ULONG
 :typecode OMG.ORG/CORBA:TC_ULONG)


(DEFCONSTANT OMG.ORG/IOP:TAG_ORB_TYPE (QUOTE 0))
(DEFCONSTANT OMG.ORG/IOP:TAG_CODE_SETS (QUOTE 1))
(DEFCONSTANT OMG.ORG/IOP:TAG_POLICIES (QUOTE 2))
(DEFCONSTANT OMG.ORG/IOP:TAG_ALTERNATE_IIOP_ADDRESS (QUOTE 3))
(DEFCONSTANT OMG.ORG/IOP:TAG_ASSOCIATION_OPTIONS (QUOTE 13))
(DEFCONSTANT OMG.ORG/IOP:TAG_SEC_NAME (QUOTE 14))
(DEFCONSTANT OMG.ORG/IOP:TAG_SPKM_1_SEC_MECH (QUOTE 15))
(DEFCONSTANT OMG.ORG/IOP:TAG_SPKM_2_SEC_MECH (QUOTE 16))
(DEFCONSTANT OMG.ORG/IOP:TAG_KERBEROSV5_SEC_MECH (QUOTE 17))
(DEFCONSTANT OMG.ORG/IOP:TAG_CSI_ECMA_SECRET_SEC_MECH (QUOTE 18))
(DEFCONSTANT OMG.ORG/IOP:TAG_CSI_ECMA_HYBRID_SEC_MECH (QUOTE 19))
(DEFCONSTANT OMG.ORG/IOP:TAG_SSL_SEC_TRANS (QUOTE 20))
(DEFCONSTANT OMG.ORG/IOP:TAG_CSI_ECMA_PUBLIC_SEC_MECH (QUOTE 21))
(DEFCONSTANT OMG.ORG/IOP:TAG_GENERIC_SEC_MECH (QUOTE 22))
(DEFCONSTANT OMG.ORG/IOP:TAG_JAVA_CODEBASE (QUOTE 25))
(DEFCONSTANT OMG.ORG/IOP:TAG_COMPLETE_OBJECT_KEY (QUOTE 5))
(DEFCONSTANT OMG.ORG/IOP:TAG_ENDPOINT_ID_POSITION (QUOTE 6))
(DEFCONSTANT OMG.ORG/IOP:TAG_LOCATION_POLICY (QUOTE 12))
(DEFCONSTANT OMG.ORG/IOP:TAG_DCE_STRING_BINDING (QUOTE 100))
(DEFCONSTANT OMG.ORG/IOP:TAG_DCE_BINDING_NAME (QUOTE 101))
(DEFCONSTANT OMG.ORG/IOP:TAG_DCE_NO_PIPES (QUOTE 102))
(DEFCONSTANT OMG.ORG/IOP:TAG_DCE_SEC_MECH (QUOTE 103))
(DEFCONSTANT OMG.ORG/IOP:TAG_FT_GROUP (QUOTE 27))


(DEFINE-STRUCT IOP:IOR
 :id "IDL:omg.org/IOP/IOR:1.0"
 :name "IOR"
 :members (("type_id" OMG.ORG/CORBA:TC_STRING)
           ("profiles"
            (create-sequence-tc 0 (SYMBOL-TYPECODE 'IOP:TAGGEDPROFILE)))))

(DEFINE-STRUCT IOP:TAGGEDPROFILE
 :id "IDL:omg.org/IOP/TaggedProfile:1.0"
 :name "TaggedProfile"
 :members (("tag" (SYMBOL-TYPECODE 'IOP:PROFILEID))
           ("profile_data" (create-sequence-tc 0 OMG.ORG/CORBA:TC_OCTET))))


(defconstant iop:tag_internet_iop (quote 0))
(defconstant iop:tag_multiple_components (quote 1))


(DEFINE-ALIAS IOP:PROFILEID
 :id "IDL:omg.org/IOP/ProfileId:1.0"
 :name "ProfileId"
 :type OMG.ORG/CORBA:ULONG
 :typecode OMG.ORG/CORBA:TC_ULONG)


(DEFINE-ALIAS IOP:ENCODINGFORMAT
 :ID "IDL:omg.org/IOP/EncodingFormat:1.0"
 :NAME "EncodingFormat"
 :TYPE OMG.ORG/CORBA:SHORT
 :TYPECODE OMG.ORG/CORBA:TC_SHORT)

(DEFCONSTANT IOP:ENCODING_CDR_ENCAPS (QUOTE 0))

(DEFINE-STRUCT IOP:ENCODING
 :ID "IDL:omg.org/IOP/Encoding:1.0"
 :NAME "Encoding"
 :MEMBERS (("format" (SYMBOL-TYPECODE 'IOP:ENCODINGFORMAT))
           ("major_version" OMG.ORG/CORBA:TC_OCTET)
           ("minor_version" OMG.ORG/CORBA:TC_OCTET))
 :READ ((BUFFER)
        (IOP:ENCODING :FORMAT (UNMARSHAL-SHORT BUFFER) :MAJOR_VERSION
         (UNMARSHAL-OCTET BUFFER) :MINOR_VERSION (UNMARSHAL-OCTET BUFFER)))
 :WRITE ((OBJ BUFFER) (MARSHAL-SHORT (OMG.ORG/FEATURES::FORMAT OBJ) BUFFER)
         (MARSHAL-OCTET (OMG.ORG/FEATURES::MAJOR_VERSION OBJ) BUFFER)
         (MARSHAL-OCTET (OMG.ORG/FEATURES::MINOR_VERSION OBJ) BUFFER)))

(DEFINE-INTERFACE IOP:CODEC (OBJECT)
 :ID "IDL:omg.org/IOP/Codec:1.0"
 :NAME "Codec")

(DEFINE-USER-EXCEPTION IOP:CODEC/INVALIDTYPEFORENCODING
 :ID "IDL:omg.org/IOP/Codec/InvalidTypeForEncoding:1.0"
 :NAME "InvalidTypeForEncoding"
 :VERSION "1.0"
 :DEFINED_IN IOP:CODEC
 :MEMBERS NIL)

(DEFINE-USER-EXCEPTION IOP:CODEC/FORMATMISMATCH
 :ID "IDL:omg.org/IOP/Codec/FormatMismatch:1.0"
 :NAME "FormatMismatch"
 :VERSION "1.0"
 :DEFINED_IN IOP:CODEC
 :MEMBERS NIL)

(DEFINE-USER-EXCEPTION IOP:CODEC/TYPEMISMATCH
 :ID "IDL:omg.org/IOP/Codec/TypeMismatch:1.0"
 :NAME "TypeMismatch"
 :VERSION "1.0"
 :DEFINED_IN IOP:CODEC
 :MEMBERS NIL)


;; (DEFINE-METHOD "ENCODE" ((OBJ IOP:CODEC-PROXY) _DATA))
;; (DEFINE-METHOD "DECODE" ((OBJ IOP:CODEC-PROXY) _DATA))
;; (DEFINE-METHOD "ENCODE_VALUE" ((OBJ IOP:CODEC-PROXY) _DATA))
;; (DEFINE-METHOD "DECODE_VALUE" ((OBJ IOP:CODEC-PROXY) _DATA _TC))


(DEFINE-INTERFACE IOP:CODECFACTORY (OBJECT)
 :ID "IDL:omg.org/IOP/CodecFactory:1.0"
 :NAME "CodecFactory")

(DEFINE-USER-EXCEPTION IOP:CODECFACTORY/UNKNOWNENCODING
 :ID "IDL:omg.org/IOP/CodecFactory/UnknownEncoding:1.0"
 :NAME "UnknownEncoding"
 :VERSION "1.0"
 :DEFINED_IN IOP:CODECFACTORY
 :MEMBERS NIL)

;; (DEFINE-METHOD "CREATE_CODEC" ((OBJ IOP:CODECFACTORY-PROXY) _ENC))
