use std::collections::{HashMap, HashSet};

use katana_cairo::cairo_vm::types::builtin_name::BuiltinName;

use crate::class::ClassHash;
use crate::contract::ContractAddress;
use crate::event::OrderedEvent;
use crate::message::OrderedL2ToL1Message;
use crate::transaction::TxType;
use crate::Felt;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct ExecutionResources {
    pub n_steps: usize,
    pub n_memory_holes: usize,
    pub builtin_instance_counter: HashMap<BuiltinName, usize>,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct TxExecInfo {
    /// Transaction validation call info; [None] for `L1Handler`.
    pub validate_call_info: Option<CallInfo>,
    /// Transaction execution call info; [None] for `Declare`.
    pub execute_call_info: Option<CallInfo>,
    /// Fee transfer call info; [None] for `L1Handler`.
    pub fee_transfer_call_info: Option<CallInfo>,
    /// The actual fee that was charged (in Wei).
    pub actual_fee: u128,
    /// Actual execution resources the transaction is charged for,
    /// including L1 gas and additional OS resources estimation.
    pub actual_resources: TxResources,
    /// Error string for reverted transactions; [None] if transaction execution was successful.
    pub revert_error: Option<String>,
    /// The transaction type of this execution info.
    pub r#type: TxType,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct TxResources {
    pub n_reverted_steps: usize,
    pub vm_resources: ExecutionResources,
    pub data_availability: L1Gas,
    pub total_gas_consumed: L1Gas,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct L1Gas {
    pub l1_gas: u128,
    pub l1_data_gas: u128,
}

/// The call type.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(::arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub enum CallType {
    #[default]
    /// Normal contract call.
    Call,
    /// Library call.
    Delegate,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub enum EntryPointType {
    #[default]
    External,
    L1Handler,
    Constructor,
}

#[derive(Debug, Clone, PartialEq, Eq, Default)]
#[cfg_attr(feature = "arbitrary", derive(::arbitrary::Arbitrary))]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
pub struct CallInfo {
    /// The contract address which the call is initiated from.
    pub caller_address: ContractAddress,
    /// The call type.
    pub call_type: CallType,
    /// The contract address.
    ///
    /// The contract address of the current call execution context. This would be the address of
    /// the contract whose code is currently being executed, or in the case of library call, the
    /// address of the contract where the library call is being initiated from.
    pub contract_address: ContractAddress,
    /// The address where the code is being executed.
    /// Optional, since there is no address to the code implementation in a delegate call.
    pub code_address: Option<ContractAddress>,
    /// The class hash, not given if it can be deduced from the storage address.
    pub class_hash: Option<ClassHash>,
    /// The entry point selector.
    pub entry_point_selector: Felt,
    /// The entry point type.
    pub entry_point_type: EntryPointType,
    /// The data used as the input to the execute entry point.
    pub calldata: Vec<Felt>,
    /// The data returned by the entry point execution.
    pub retdata: Vec<Felt>,
    /// The resources used by the execution.
    pub execution_resources: ExecutionResources,
    /// The list of ordered events generated by the execution.
    pub events: Vec<OrderedEvent>,
    /// The list of ordered l2 to l1 messages generated by the execution.
    pub l2_to_l1_messages: Vec<OrderedL2ToL1Message>,
    /// The list of storage addresses being read during the execution.
    pub storage_read_values: Vec<Felt>,
    /// The list of storage addresses being accessed during the execution.
    pub accessed_storage_keys: HashSet<Felt>,
    /// The list of inner calls triggered by the current call.
    pub inner_calls: Vec<CallInfo>,
    /// The total gas consumed by the call.
    pub gas_consumed: u128,
    /// True if the execution has failed, false otherwise.
    pub failed: bool,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "serde", derive(serde::Serialize, serde::Deserialize))]
#[serde(transparent)]
pub struct BuiltinCounters(HashMap<BuiltinName, usize>);

impl BuiltinCounters {
    /// Returns the number of instances of the `output` builtin, if any.
    pub fn output(&self) -> Option<u64> {
        self.builtin(BuiltinName::output)
    }

    /// Returns the number of instances of the `range_check` builtin, if any.
    pub fn range_check(&self) -> Option<u64> {
        self.builtin(BuiltinName::range_check)
    }

    /// Returns the number of instances of the `pedersen` builtin, if any.
    pub fn pedersen(&self) -> Option<u64> {
        self.builtin(BuiltinName::pedersen)
    }

    /// Returns the number of instances of the `ecdsa` builtin, if any.
    pub fn ecdsa(&self) -> Option<u64> {
        self.builtin(BuiltinName::ecdsa)
    }

    /// Returns the number of instances of the `keccak` builtin, if any.
    pub fn keccak(&self) -> Option<u64> {
        self.builtin(BuiltinName::keccak)
    }

    /// Returns the number of instances of the `bitwise` builtin, if any.
    pub fn bitwise(&self) -> Option<u64> {
        self.builtin(BuiltinName::bitwise)
    }

    /// Returns the number of instances of the `ec_op` builtin, if any.
    pub fn ec_op(&self) -> Option<u64> {
        self.builtin(BuiltinName::ec_op)
    }

    /// Returns the number of instances of the `poseidon` builtin, if any.
    pub fn poseidon(&self) -> Option<u64> {
        self.builtin(BuiltinName::poseidon)
    }

    /// Returns the number of instances of the `segment_arena` builtin, if any.
    pub fn segment_arena(&self) -> Option<u64> {
        self.builtin(BuiltinName::segment_arena)
    }

    /// Returns the number of instances of the `range_check96` builtin, if any.
    pub fn range_check96(&self) -> Option<u64> {
        self.builtin(BuiltinName::range_check96)
    }

    /// Returns the number of instances of the `add_mod` builtin, if any.
    pub fn add_mod(&self) -> Option<u64> {
        self.builtin(BuiltinName::add_mod)
    }

    /// Returns the number of instances of the `mul_mod` builtin, if any.
    pub fn mul_mod(&self) -> Option<u64> {
        self.builtin(BuiltinName::mul_mod)
    }

    fn builtin(&self, builtin: BuiltinName) -> Option<u64> {
        self.0.get(&builtin).map(|&x| x as u64)
    }
}

impl From<HashMap<BuiltinName, usize>> for BuiltinCounters {
    fn from(map: HashMap<BuiltinName, usize>) -> Self {
        // Filter out the builtins with 0 count.
        let filtered = map.into_iter().filter(|(_, count)| *count != 0).collect();
        BuiltinCounters(filtered)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_builtin_counters_from_hashmap_removes_zero_entries() {
        let mut map = HashMap::new();
        map.insert(BuiltinName::output, 1);
        map.insert(BuiltinName::range_check, 0);
        map.insert(BuiltinName::pedersen, 2);
        map.insert(BuiltinName::ecdsa, 0);

        let counters = BuiltinCounters::from(map);

        assert_eq!(counters.output(), Some(1));
        assert_eq!(counters.range_check(), None);
        assert_eq!(counters.pedersen(), Some(2));
        assert_eq!(counters.ecdsa(), None);
    }
}
