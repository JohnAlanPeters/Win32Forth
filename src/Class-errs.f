\ $Id: Class-errs.f,v 1.3 2012/02/26 16:43:58 georgeahubert Exp $

\ : .THROW-CODES CELL+ DUP @ 6 .R  6 SPACES CELL+ COUNT TYPE CR ;

\ : THROW-CODES CR ['] .THROW-CODES THROW_MSGS DO-LINK ;

\ Throw codes for classes

 in-system

-350
DUP 1- SWAP CONSTANT THROW_NEED_SEL
DUP 1- SWAP CONSTANT THROW_NOT_SEL
DUP 1- SWAP CONSTANT THROW_NOT_SELF
DUP 1- SWAP CONSTANT THROW_NO_BITS
DUP 1- SWAP CONSTANT THROW_ZERO_BITS
DUP 1- SWAP CONSTANT THROW_BIG_BITS
DUP 1- SWAP CONSTANT THROW_NOT_IN_CLASS
DUP 1- SWAP CONSTANT THROW_IVAR_EXISTS
DUP 1- SWAP CONSTANT THROW_NEW>
DUP 1- SWAP CONSTANT THROW_NOT_CLASS_OR_OBJ
DUP 1- SWAP CONSTANT THROW_NO_CLONE
DUP 1- SWAP CONSTANT THROW_NOT_CLASS
DUP 1- SWAP CONSTANT THROW_NOT_OBJ
DUP 1- SWAP CONSTANT THROW_NOT_METHOD
DUP 1- SWAP CONSTANT THROW_INVALID_OBJ_REF
DUP 1- SWAP CONSTANT THROW_NO_FIND_VAR
DUP 1- SWAP CONSTANT THROW_INVALID_IVAR
DUP 1- SWAP CONSTANT THROW_NO_FIND_OBJ
DUP 1- SWAP CONSTANT THROW_OBJ_EXPOSED
DUP 1- SWAP CONSTANT THROW_NO_WM
DUP 1- SWAP CONSTANT THROW_METH_BUFF_OVERFLOW
DUP 1- SWAP CONSTANT THROW_UNDEF_METH

 in-previous

DUP 1- SWAP CONSTANT THROW_INDEX_OFR
DUP 1- SWAP CONSTANT THROW_DISPOSE_ERR

DROP

 in-system

THROW_MSGS LINK, THROW_NEED_SEL             , ," must be preceeded by a selector "
THROW_MSGS LINK, THROW_NOT_SEL              , ," not a selector"
THROW_MSGS LINK, THROW_NOT_SELF             , ," Use only for self-reference to object"
THROW_MSGS LINK, THROW_NO_BITS              , ," Bit fields are not allowed on this data type"
THROW_MSGS LINK, THROW_ZERO_BITS            , ," Zero length bit fields are not allowed"
THROW_MSGS LINK, THROW_BIG_BITS             , ," Bit field exceeded bits allowed in this field"
THROW_MSGS LINK, THROW_NOT_IN_CLASS         , ," Not in a class"
THROW_MSGS LINK, THROW_IVAR_EXISTS          , ," Duplicate Instance Variable"
THROW_MSGS LINK, THROW_NEW>                 , ," Use: New> classname"
THROW_MSGS LINK, THROW_NOT_CLASS_OR_OBJ     , ," not a class or object"
THROW_MSGS LINK, THROW_NO_CLONE             , ," Can only clone Objects"
THROW_MSGS LINK, THROW_NOT_CLASS            , ," Classes must start with :Class or |Class"
THROW_MSGS LINK, THROW_NOT_OBJ              , ," Objects must start with :Object"
THROW_MSGS LINK, THROW_NOT_METHOD           , ," Methods must START with :M !"
THROW_MSGS LINK, THROW_INVALID_OBJ_REF      , ," Invalid object type"
THROW_MSGS LINK, THROW_NO_FIND_VAR          , ," Can't find Variable"
THROW_MSGS LINK, THROW_INVALID_IVAR         , ," Can ONLY use DOT notation on BYTE, SHORT, INT, BYTES or RECORD:"
THROW_MSGS LINK, THROW_NO_FIND_OBJ          , ," Can't find object"
THROW_MSGS LINK, THROW_OBJ_EXPOSED          , ," No object exposed"
THROW_MSGS LINK, THROW_NO_WM                , ," Must be preceeded by a WM_MESSAGE"
THROW_MSGS LINK, THROW_METH_BUFF_OVERFLOW   , ," Unresolved Methods buffer overflow!"
THROW_MSGS LINK, THROW_UNDEF_METH           , ," Undefined Method"

 in-previous

THROW_MSGS LINK, THROW_INDEX_OFR            , ," Index out of range"
THROW_MSGS LINK, THROW_DISPOSE_ERR          , ," Disposing Object failed!"


