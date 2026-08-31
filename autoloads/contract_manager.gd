extends Node

var available_contracts: Array[ContractData] = []
var active_assignments: Dictionary = {}  # ContractData -> StaffData

func deliver_contract(contract: ContractData, on_time: bool) -> void:
	var payout_amount: int
	if on_time:
		payout_amount = contract.payout
		print("Delivered contract '%s' ON TIME! Full payout: %d" % [contract.contract_title, payout_amount])
	else:
		payout_amount = int(contract.payout * 0.9)
		print("Delivered contract '%s' LATE! Reduced payout (90%%): %d" % [contract.contract_title, payout_amount])
	
	Economy.add_currency(payout_amount)
	active_assignments.erase(contract)
