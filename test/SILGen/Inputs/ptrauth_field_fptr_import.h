#ifndef TEST_C_FUNCTION
#define TEST_C_FUNCTION

struct SecureStruct {
  int (*__ptrauth(1, 0, 88)(secure_func_ptr1))();
  int (*__ptrauth(1, 0, 66)(secure_func_ptr2))();
};

struct AddressDiscriminatedSecureStruct {
  int (*__ptrauth(1, 1, 88)(secure_func_ptr1))();
  int (*__ptrauth(1, 1, 66)(secure_func_ptr2))();
};

// Nests an address-diversified ptrauth struct by value: the nested field is
// PCK_Struct, not PCK_PtrAuth.
struct NestedSecureStruct {
  struct AddressDiscriminatedSecureStruct base;
  int (*__ptrauth(1, 1, 99)(secure_func_ptr3))();
};

struct SecureStruct *ptr_to_secure_struct;
struct AddressDiscriminatedSecureStruct
    *ptr_to_addr_discriminated_secure_struct;
struct NestedSecureStruct *ptr_to_nested_secure_struct;
#endif
