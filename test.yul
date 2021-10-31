IR:
/*=====================================================*
 *                       WARNING                       *
 *  Solidity to Yul compilation is still EXPERIMENTAL  *
 *       It can result in LOSS OF FUNDS or worse       *
 *                !USE AT YOUR OWN RISK!               *
 *=====================================================*/


object "Auth_144" {
    code {
        /// @src 0:630,1764
        mstore(64, 128)
        if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }

        let _1, _2 := copy_arguments_for_constructor_54_object_Auth_144()
        constructor_Auth_144(_1, _2)

        let _3 := allocate_unbounded()
        codecopy(_3, dataoffset("Auth_144_deployed"), datasize("Auth_144_deployed"))

        return(_3, datasize("Auth_144_deployed"))

        function abi_decode_t_address_fromMemory(offset, end) -> value {
            value := mload(offset)
            validator_revert_t_address(value)
        }

        function abi_decode_t_contract$_Authority_$14_fromMemory(offset, end) -> value {
            value := mload(offset)
            validator_revert_t_contract$_Authority_$14(value)
        }

        function abi_decode_tuple_t_addresst_contract$_Authority_$14_fromMemory(headStart, dataEnd) -> value0, value1 {
            if slt(sub(dataEnd, headStart), 64) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

            {

                let offset := 0

                value0 := abi_decode_t_address_fromMemory(add(headStart, offset), dataEnd)
            }

            {

                let offset := 32

                value1 := abi_decode_t_contract$_Authority_$14_fromMemory(add(headStart, offset), dataEnd)
            }

        }

        function abi_encode_tuple__to__fromStack(headStart ) -> tail {
            tail := add(headStart, 0)

        }

        function allocate_memory(size) -> memPtr {
            memPtr := allocate_unbounded()
            finalize_allocation(memPtr, size)
        }

        function allocate_unbounded() -> memPtr {
            memPtr := mload(64)
        }

        function cleanup_t_address(value) -> cleaned {
            cleaned := cleanup_t_uint160(value)
        }

        function cleanup_t_contract$_Authority_$14(value) -> cleaned {
            cleaned := cleanup_t_address(value)
        }

        function cleanup_t_uint160(value) -> cleaned {
            cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
        }

        function constructor_Auth_144(var__owner_31, var__authority_34_address) {

            /// @src 0:816,1008

            /// @src 0:884,890
            let _4 := var__owner_31
            let expr_38 := _4
            /// @src 0:876,890
            update_storage_value_offset_0t_address_to_t_address(0x00, expr_38)
            let expr_39 := expr_38
            /// @src 0:912,922
            let _5_address := var__authority_34_address
            let expr_42_address := _5_address
            /// @src 0:900,922
            update_storage_value_offset_0t_contract$_Authority_$14_to_t_contract$_Authority_$14(0x01, expr_42_address)
            let expr_43_address := expr_42_address
            /// @src 0:951,957
            let _6 := var__owner_31
            let expr_46 := _6
            /// @src 0:938,958
            let _7 := 0x4ffd725fc4a22075e9ec71c59edf9c38cdeb588a91b24fc5b61388c5be41282b
            {
                let _8 := allocate_unbounded()
                let _9 := abi_encode_tuple__to__fromStack(_8 )
                log2(_8, sub(_9, _8) , _7, expr_46)
            }/// @src 0:990,1000
            let _10_address := var__authority_34_address
            let expr_50_address := _10_address
            /// @src 0:973,1001
            let _11 := 0x2f658b440c35314f52658ea8a740e05b284cdc84dc9ae01e891f21b8933e7cad
            {
                let _12 := allocate_unbounded()
                let _13 := abi_encode_tuple__to__fromStack(_12 )
                log2(_12, sub(_13, _12) , _11, expr_50_address)
            }
        }

        function convert_t_address_to_t_address(value) -> converted {
            converted := convert_t_uint160_to_t_address(value)
        }

        function convert_t_contract$_Authority_$14_to_t_contract$_Authority_$14(value) -> converted {
            converted := cleanup_t_uint160(value)
        }

        function convert_t_uint160_to_t_address(value) -> converted {
            converted := convert_t_uint160_to_t_uint160(value)
        }

        function convert_t_uint160_to_t_uint160(value) -> converted {
            converted := cleanup_t_uint160(value)
        }

        function copy_arguments_for_constructor_54_object_Auth_144() -> ret_param_0, ret_param_1 {
            let programSize := datasize("Auth_144")
            let argSize := sub(codesize(), programSize)

            let memoryDataOffset := allocate_memory(argSize)
            codecopy(memoryDataOffset, programSize, argSize)

            ret_param_0, ret_param_1 := abi_decode_tuple_t_addresst_contract$_Authority_$14_fromMemory(memoryDataOffset, add(memoryDataOffset, argSize))
        }

        function finalize_allocation(memPtr, size) {
            let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
            // protect against overflow
            if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
            mstore(64, newFreePtr)
        }

        function panic_error_0x41() {
            mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
            mstore(4, 0x41)
            revert(0, 0x24)
        }

        function prepare_store_t_address(value) -> ret {
            ret := value
        }

        function prepare_store_t_contract$_Authority_$14(value) -> ret {
            ret := value
        }

        function revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() {
            revert(0, 0)
        }

        function revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() {
            revert(0, 0)
        }

        function revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() {
            revert(0, 0)
        }

        function round_up_to_mul_of_32(value) -> result {
            result := and(add(value, 31), not(31))
        }

        function shift_left_0(value) -> newValue {
            newValue :=

            shl(0, value)

        }

        function update_byte_slice_20_shift_0(value, toInsert) -> result {
            let mask := 0xffffffffffffffffffffffffffffffffffffffff
            toInsert := shift_left_0(toInsert)
            value := and(value, not(mask))
            result := or(value, and(toInsert, mask))
        }

        function update_storage_value_offset_0t_address_to_t_address(slot, value_0) {
            let convertedValue_0 := convert_t_address_to_t_address(value_0)
            sstore(slot, update_byte_slice_20_shift_0(sload(slot), prepare_store_t_address(convertedValue_0)))
        }

        function update_storage_value_offset_0t_contract$_Authority_$14_to_t_contract$_Authority_$14(slot, value_0) {
            let convertedValue_0 := convert_t_contract$_Authority_$14_to_t_contract$_Authority_$14(value_0)
            sstore(slot, update_byte_slice_20_shift_0(sload(slot), prepare_store_t_contract$_Authority_$14(convertedValue_0)))
        }

        function validator_revert_t_address(value) {
            if iszero(eq(value, cleanup_t_address(value))) { revert(0, 0) }
        }

        function validator_revert_t_contract$_Authority_$14(value) {
            if iszero(eq(value, cleanup_t_contract$_Authority_$14(value))) { revert(0, 0) }
        }

    }
    object "Auth_144_deployed" {
        code {
            /// @src 0:630,1764
            mstore(64, 128)

            if iszero(lt(calldatasize(), 4))
            {
                let selector := shift_right_224_unsigned(calldataload(0))
                switch selector

                case 0x13af4035
                {
                    // setOwner(address)

                    if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }
                    let param_0 :=  abi_decode_tuple_t_address(4, calldatasize())
                    fun_setOwner_70(param_0)
                    let memPos := allocate_unbounded()
                    let memEnd := abi_encode_tuple__to__fromStack(memPos  )
                    return(memPos, sub(memEnd, memPos))
                }

                case 0x7a9e5e4b
                {
                    // setAuthority(address)

                    if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }
                    let param_0 :=  abi_decode_tuple_t_contract$_Authority_$14(4, calldatasize())
                    fun_setAuthority_87(param_0)
                    let memPos := allocate_unbounded()
                    let memEnd := abi_encode_tuple__to__fromStack(memPos  )
                    return(memPos, sub(memEnd, memPos))
                }

                case 0x8da5cb5b
                {
                    // owner()

                    if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }
                    abi_decode_tuple_(4, calldatasize())
                    let ret_0 :=  getter_fun_owner_26()
                    let memPos := allocate_unbounded()
                    let memEnd := abi_encode_tuple_t_address__to_t_address__fromStack(memPos , ret_0)
                    return(memPos, sub(memEnd, memPos))
                }

                case 0xbf7e214f
                {
                    // authority()

                    if callvalue() { revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() }
                    abi_decode_tuple_(4, calldatasize())
                    let ret_0 :=  getter_fun_authority_29()
                    let memPos := allocate_unbounded()
                    let memEnd := abi_encode_tuple_t_contract$_Authority_$14__to_t_address__fromStack(memPos , ret_0)
                    return(memPos, sub(memEnd, memPos))
                }

                default {}
            }
            if iszero(calldatasize()) {  }
            revert_error_42b3090547df1d2001c96683413b8cf91c1b902ef5e3cb8d9f6f304cf7446f74()

            function abi_decode_t_address(offset, end) -> value {
                value := calldataload(offset)
                validator_revert_t_address(value)
            }

            function abi_decode_t_bool_fromMemory(offset, end) -> value {
                value := mload(offset)
                validator_revert_t_bool(value)
            }

            function abi_decode_t_contract$_Authority_$14(offset, end) -> value {
                value := calldataload(offset)
                validator_revert_t_contract$_Authority_$14(value)
            }

            function abi_decode_tuple_(headStart, dataEnd)   {
                if slt(sub(dataEnd, headStart), 0) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

            }

            function abi_decode_tuple_t_address(headStart, dataEnd) -> value0 {
                if slt(sub(dataEnd, headStart), 32) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

                {

                    let offset := 0

                    value0 := abi_decode_t_address(add(headStart, offset), dataEnd)
                }

            }

            function abi_decode_tuple_t_bool_fromMemory(headStart, dataEnd) -> value0 {
                if slt(sub(dataEnd, headStart), 32) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

                {

                    let offset := 0

                    value0 := abi_decode_t_bool_fromMemory(add(headStart, offset), dataEnd)
                }

            }

            function abi_decode_tuple_t_contract$_Authority_$14(headStart, dataEnd) -> value0 {
                if slt(sub(dataEnd, headStart), 32) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

                {

                    let offset := 0

                    value0 := abi_decode_t_contract$_Authority_$14(add(headStart, offset), dataEnd)
                }

            }

            function abi_encode_t_address_to_t_address_fromStack(value, pos) {
                mstore(pos, cleanup_t_address(value))
            }

            function abi_encode_t_bytes4_to_t_bytes4_fromStack(value, pos) {
                mstore(pos, cleanup_t_bytes4(value))
            }

            function abi_encode_t_contract$_Authority_$14_to_t_address_fromStack(value, pos) {
                mstore(pos, convert_t_contract$_Authority_$14_to_t_address(value))
            }

            function abi_encode_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528_to_t_string_memory_ptr_fromStack(pos) -> end {
                pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 12)
                store_literal_in_memory_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528(pos)
                end := add(pos, 32)
            }

            function abi_encode_tuple__to__fromStack(headStart ) -> tail {
                tail := add(headStart, 0)

            }

            function abi_encode_tuple_t_address__to_t_address__fromStack(headStart , value0) -> tail {
                tail := add(headStart, 32)

                abi_encode_t_address_to_t_address_fromStack(value0,  add(headStart, 0))

            }

            function abi_encode_tuple_t_address_t_address_t_bytes4__to_t_address_t_address_t_bytes4__fromStack(headStart , value0, value1, value2) -> tail {
                tail := add(headStart, 96)

                abi_encode_t_address_to_t_address_fromStack(value0,  add(headStart, 0))

                abi_encode_t_address_to_t_address_fromStack(value1,  add(headStart, 32))

                abi_encode_t_bytes4_to_t_bytes4_fromStack(value2,  add(headStart, 64))

            }

            function abi_encode_tuple_t_contract$_Authority_$14__to_t_address__fromStack(headStart , value0) -> tail {
                tail := add(headStart, 32)

                abi_encode_t_contract$_Authority_$14_to_t_address_fromStack(value0,  add(headStart, 0))

            }

            function abi_encode_tuple_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528__to_t_string_memory_ptr__fromStack(headStart ) -> tail {
                tail := add(headStart, 32)

                mstore(add(headStart, 0), sub(tail, headStart))
                tail := abi_encode_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528_to_t_string_memory_ptr_fromStack( tail)

            }

            function allocate_unbounded() -> memPtr {
                memPtr := mload(64)
            }

            function array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, length) -> updated_pos {
                mstore(pos, length)
                updated_pos := add(pos, 0x20)
            }

            function cleanup_from_storage_t_address(value) -> cleaned {
                cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
            }

            function cleanup_from_storage_t_contract$_Authority_$14(value) -> cleaned {
                cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
            }

            function cleanup_t_address(value) -> cleaned {
                cleaned := cleanup_t_uint160(value)
            }

            function cleanup_t_bool(value) -> cleaned {
                cleaned := iszero(iszero(value))
            }

            function cleanup_t_bytes4(value) -> cleaned {
                cleaned := and(value, 0xffffffff00000000000000000000000000000000000000000000000000000000)
            }

            function cleanup_t_contract$_Authority_$14(value) -> cleaned {
                cleaned := cleanup_t_address(value)
            }

            function cleanup_t_uint160(value) -> cleaned {
                cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
            }

            function convert_t_address_to_t_address(value) -> converted {
                converted := convert_t_uint160_to_t_address(value)
            }

            function convert_t_contract$_Auth_$144_to_t_address(value) -> converted {
                converted := convert_t_contract$_Auth_$144_to_t_uint160(value)
            }

            function convert_t_contract$_Auth_$144_to_t_uint160(value) -> converted {
                converted := cleanup_t_uint160(value)
            }

            function convert_t_contract$_Authority_$14_to_t_address(value) -> converted {
                converted := convert_t_contract$_Authority_$14_to_t_uint160(value)
            }

            function convert_t_contract$_Authority_$14_to_t_contract$_Authority_$14(value) -> converted {
                converted := cleanup_t_uint160(value)
            }

            function convert_t_contract$_Authority_$14_to_t_uint160(value) -> converted {
                converted := cleanup_t_uint160(value)
            }

            function convert_t_rational_0_by_1_to_t_address(value) -> converted {
                converted := convert_t_rational_0_by_1_to_t_uint160(value)
            }

            function convert_t_rational_0_by_1_to_t_uint160(value) -> converted {
                converted := cleanup_t_uint160(value)
            }

            function convert_t_uint160_to_t_address(value) -> converted {
                converted := convert_t_uint160_to_t_uint160(value)
            }

            function convert_t_uint160_to_t_uint160(value) -> converted {
                converted := cleanup_t_uint160(value)
            }

            function extract_from_storage_value_dynamict_address(slot_value, offset) -> value {
                value := cleanup_from_storage_t_address(shift_right_unsigned_dynamic(mul(offset, 8), slot_value))
            }

            function extract_from_storage_value_dynamict_contract$_Authority_$14(slot_value, offset) -> value {
                value := cleanup_from_storage_t_contract$_Authority_$14(shift_right_unsigned_dynamic(mul(offset, 8), slot_value))
            }

            function extract_from_storage_value_offset_0t_address(slot_value) -> value {
                value := cleanup_from_storage_t_address(shift_right_0_unsigned(slot_value))
            }

            function extract_from_storage_value_offset_0t_contract$_Authority_$14(slot_value) -> value {
                value := cleanup_from_storage_t_contract$_Authority_$14(shift_right_0_unsigned(slot_value))
            }

            function finalize_allocation(memPtr, size) {
                let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
                // protect against overflow
                if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
                mstore(64, newFreePtr)
            }

            function fun_isAuthorized_129(var_user_89, var_functionSig_91) -> var__94 {
                /// @src 0:1316,1645
                /// @src 0:1403,1407
                let zero_t_bool_11 := zero_value_for_split_t_bool()
                var__94 := zero_t_bool_11

                /// @src 0:1447,1456
                let _12_address := read_from_storage_split_offset_0_t_contract$_Authority_$14(0x01)
                let expr_99_address := _12_address
                /// @src 0:1419,1456
                let var_cachedAuthority_98_address := expr_99_address
                /// @src 0:1479,1494
                let _13_address := var_cachedAuthority_98_address
                let expr_103_address := _13_address
                /// @src 0:1471,1495
                let expr_104 := convert_t_contract$_Authority_$14_to_t_address(expr_103_address)
                /// @src 0:1507,1508
                let expr_107 := 0x00
                /// @src 0:1499,1509
                let expr_108 := convert_t_rational_0_by_1_to_t_address(expr_107)
                /// @src 0:1471,1509
                let expr_109 := iszero(eq(cleanup_t_address(expr_104), cleanup_t_address(expr_108)))
                /// @src 0:1471,1570
                let expr_119 := expr_109
                if expr_119 {
                    /// @src 0:1513,1528
                    let _14_address := var_cachedAuthority_98_address
                    let expr_110_address := _14_address
                    /// @src 0:1513,1536
                    let expr_111_address := convert_t_contract$_Authority_$14_to_t_address(expr_110_address)
                    let expr_111_functionSelector := 0xb7009613
                    /// @src 0:1537,1541
                    let _15 := var_user_89
                    let expr_112 := _15
                    /// @src 0:1551,1555
                    let expr_115_address := address()
                    /// @src 0:1543,1556
                    let expr_116 := convert_t_contract$_Auth_$144_to_t_address(expr_115_address)
                    /// @src 0:1558,1569
                    let _16 := var_functionSig_91
                    let expr_117 := _16
                    /// @src 0:1513,1570
                    if iszero(extcodesize(expr_111_address)) { revert_error_0cc013b6b3b6beabea4e3a74a6d380f0df81852ca99887912475e1f66b2a2c20() }

                    // storage for arguments and returned data
                    let _17 := allocate_unbounded()
                    mstore(_17, shift_left_224(expr_111_functionSelector))
                    let _18 := abi_encode_tuple_t_address_t_address_t_bytes4__to_t_address_t_address_t_bytes4__fromStack(add(_17, 4) , expr_112, expr_116, expr_117)

                    let _19 := staticcall(gas(), expr_111_address,  _17, sub(_18, _17), _17, 32)

                    if iszero(_19) { revert_forward_1() }

                    let expr_118
                    if _19 {

                        // update freeMemoryPointer according to dynamic return size
                        finalize_allocation(_17, returndatasize())

                        // decode return parameters from external try-call into retVars
                        expr_118 :=  abi_decode_tuple_t_bool_fromMemory(_17, add(_17, returndatasize()))
                    }
                    /// @src 0:1471,1570
                    expr_119 := expr_118
                }
                /// @src 0:1467,1608
                if expr_119 {
                    /// @src 0:1593,1597
                    let expr_120 := 0x01
                    /// @src 0:1586,1597
                    var__94 := expr_120
                    leave
                    /// @src 0:1467,1608
                }
                /// @src 0:1625,1629
                let _20 := var_user_89
                let expr_124 := _20
                /// @src 0:1633,1638
                let _21 := read_from_storage_split_offset_0_t_address(0x00)
                let expr_125 := _21
                /// @src 0:1625,1638
                let expr_126 := eq(cleanup_t_address(expr_124), cleanup_t_address(expr_125))
                /// @src 0:1618,1638
                var__94 := expr_126
                leave

            }

            function fun_setAuthority_87(var_newAuthority_73_address) {
                /// @src 0:1152,1310

                modifier_requiresAuth_76(var_newAuthority_73_address)
            }

            function fun_setAuthority_87_inner(var_newAuthority_73_address) {
                /// @src 0:1152,1310

                /// @src 0:1248,1260
                let _6_address := var_newAuthority_73_address
                let expr_79_address := _6_address
                /// @src 0:1236,1260
                update_storage_value_offset_0t_contract$_Authority_$14_to_t_contract$_Authority_$14(0x01, expr_79_address)
                let expr_80_address := expr_79_address
                /// @src 0:1293,1302
                let _7_address := read_from_storage_split_offset_0_t_contract$_Authority_$14(0x01)
                let expr_83_address := _7_address
                /// @src 0:1276,1303
                let _8 := 0x2f658b440c35314f52658ea8a740e05b284cdc84dc9ae01e891f21b8933e7cad
                {
                    let _9 := allocate_unbounded()
                    let _10 := abi_encode_tuple__to__fromStack(_9 )
                    log2(_9, sub(_10, _9) , _8, expr_83_address)
                }
            }

            function fun_setOwner_70(var_newOwner_56) {
                /// @src 0:1014,1146

                modifier_requiresAuth_59(var_newOwner_56)
            }

            function fun_setOwner_70_inner(var_newOwner_56) {
                /// @src 0:1014,1146

                /// @src 0:1096,1104
                let _1 := var_newOwner_56
                let expr_62 := _1
                /// @src 0:1088,1104
                update_storage_value_offset_0t_address_to_t_address(0x00, expr_62)
                let expr_63 := expr_62
                /// @src 0:1133,1138
                let _2 := read_from_storage_split_offset_0_t_address(0x00)
                let expr_66 := _2
                /// @src 0:1120,1139
                let _3 := 0x4ffd725fc4a22075e9ec71c59edf9c38cdeb588a91b24fc5b61388c5be41282b
                {
                    let _4 := allocate_unbounded()
                    let _5 := abi_encode_tuple__to__fromStack(_4 )
                    log2(_4, sub(_5, _4) , _3, expr_66)
                }
            }

            function getter_fun_authority_29() -> ret_address {
                /// @src 0:783,809

                let slot := 1
                let offset := 0

                ret_address := read_from_storage_split_dynamic_t_contract$_Authority_$14(slot, offset)

            }

            function getter_fun_owner_26() -> ret {
                /// @src 0:756,776

                let slot := 0
                let offset := 0

                ret := read_from_storage_split_dynamic_t_address(slot, offset)

            }

            function modifier_requiresAuth_59(var_newOwner_56) {
                /// @src 0:1651,1762

                /// @src 0:1693,1705
                let expr_132_functionIdentifier := 129
                /// @src 0:1706,1716
                let expr_134 := caller()
                /// @src 0:1718,1725
                let expr_136 := and(calldataload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)
                /// @src 0:1693,1726
                let expr_137 := fun_isAuthorized_129(expr_134, expr_136)
                /// @src 0:1685,1743
                require_helper_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528(expr_137)
                /// @src 0:1754,1755
                fun_setOwner_70_inner(var_newOwner_56)

            }

            function modifier_requiresAuth_76(var_newAuthority_73_address) {
                /// @src 0:1651,1762

                /// @src 0:1693,1705
                let expr_132_functionIdentifier := 129
                /// @src 0:1706,1716
                let expr_134 := caller()
                /// @src 0:1718,1725
                let expr_136 := and(calldataload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)
                /// @src 0:1693,1726
                let expr_137 := fun_isAuthorized_129(expr_134, expr_136)
                /// @src 0:1685,1743
                require_helper_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528(expr_137)
                /// @src 0:1754,1755
                fun_setAuthority_87_inner(var_newAuthority_73_address)

            }

            function panic_error_0x41() {
                mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
                mstore(4, 0x41)
                revert(0, 0x24)
            }

            function prepare_store_t_address(value) -> ret {
                ret := value
            }

            function prepare_store_t_contract$_Authority_$14(value) -> ret {
                ret := value
            }

            function read_from_storage_split_dynamic_t_address(slot, offset) -> value {
                value := extract_from_storage_value_dynamict_address(sload(slot), offset)

            }

            function read_from_storage_split_dynamic_t_contract$_Authority_$14(slot, offset) -> value {
                value := extract_from_storage_value_dynamict_contract$_Authority_$14(sload(slot), offset)

            }

            function read_from_storage_split_offset_0_t_address(slot) -> value {
                value := extract_from_storage_value_offset_0t_address(sload(slot))

            }

            function read_from_storage_split_offset_0_t_contract$_Authority_$14(slot) -> value {
                value := extract_from_storage_value_offset_0t_contract$_Authority_$14(sload(slot))

            }

            function require_helper_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528(condition ) {
                if iszero(condition) {
                    let memPtr := allocate_unbounded()
                    mstore(memPtr, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    let end := abi_encode_tuple_t_stringliteral_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528__to_t_string_memory_ptr__fromStack(add(memPtr, 4) )
                    revert(memPtr, sub(end, memPtr))
                }
            }

            function revert_error_0cc013b6b3b6beabea4e3a74a6d380f0df81852ca99887912475e1f66b2a2c20() {
                revert(0, 0)
            }

            function revert_error_42b3090547df1d2001c96683413b8cf91c1b902ef5e3cb8d9f6f304cf7446f74() {
                revert(0, 0)
            }

            function revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() {
                revert(0, 0)
            }

            function revert_error_ca66f745a3ce8ff40e2ccaf1ad45db7774001b90d25810abd9040049be7bf4bb() {
                revert(0, 0)
            }

            function revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() {
                revert(0, 0)
            }

            function revert_forward_1() {
                let pos := allocate_unbounded()
                returndatacopy(pos, 0, returndatasize())
                revert(pos, returndatasize())
            }

            function round_up_to_mul_of_32(value) -> result {
                result := and(add(value, 31), not(31))
            }

            function shift_left_0(value) -> newValue {
                newValue :=

                shl(0, value)

            }

            function shift_left_224(value) -> newValue {
                newValue :=

                shl(224, value)

            }

            function shift_right_0_unsigned(value) -> newValue {
                newValue :=

                shr(0, value)

            }

            function shift_right_224_unsigned(value) -> newValue {
                newValue :=

                shr(224, value)

            }

            function shift_right_unsigned_dynamic(bits, value) -> newValue {
                newValue :=

                shr(bits, value)

            }

            function store_literal_in_memory_269df367cd41cace5897a935d0e0858fe4543b5619d45e09af6b124c1bb3d528(memPtr) {

                mstore(add(memPtr, 0), "UNAUTHORIZED")

            }

            function update_byte_slice_20_shift_0(value, toInsert) -> result {
                let mask := 0xffffffffffffffffffffffffffffffffffffffff
                toInsert := shift_left_0(toInsert)
                value := and(value, not(mask))
                result := or(value, and(toInsert, mask))
            }

            function update_storage_value_offset_0t_address_to_t_address(slot, value_0) {
                let convertedValue_0 := convert_t_address_to_t_address(value_0)
                sstore(slot, update_byte_slice_20_shift_0(sload(slot), prepare_store_t_address(convertedValue_0)))
            }

            function update_storage_value_offset_0t_contract$_Authority_$14_to_t_contract$_Authority_$14(slot, value_0) {
                let convertedValue_0 := convert_t_contract$_Authority_$14_to_t_contract$_Authority_$14(value_0)
                sstore(slot, update_byte_slice_20_shift_0(sload(slot), prepare_store_t_contract$_Authority_$14(convertedValue_0)))
            }

            function validator_revert_t_address(value) {
                if iszero(eq(value, cleanup_t_address(value))) { revert(0, 0) }
            }

            function validator_revert_t_bool(value) {
                if iszero(eq(value, cleanup_t_bool(value))) { revert(0, 0) }
            }

            function validator_revert_t_contract$_Authority_$14(value) {
                if iszero(eq(value, cleanup_t_contract$_Authority_$14(value))) { revert(0, 0) }
            }

            function zero_value_for_split_t_bool() -> ret {
                ret := 0
            }

        }

        data ".metadata" hex"a26469706673582212207ef838b5a02b45edf0bf4215e24a6b0d3361ef4adc6555df9fa31b88c4bd5f6e64736f6c63430008060033"
    }

}


IR:

