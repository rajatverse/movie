class_name EconomyTest
extends Node

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING ECONOMY TESTS ===")
	test_add_currency()
	test_try_spend_success()
	test_try_spend_failure()
	print("Economy Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func test_add_currency() -> void:
	var initial_balance: int = Economy.currency
	var signal_data: Dictionary = {"emitted": false, "balance": -1}
	
	var callback = func(amount: int):
		signal_data["emitted"] = true
		signal_data["balance"] = amount
		
	Economy.currency_changed.connect(callback)
	Economy.add_currency(500)
	
	assert_true(Economy.currency == initial_balance + 500, "Economy.add_currency(500) updated balance from %d to %d" % [initial_balance, initial_balance + 500])
	assert_true(signal_data["emitted"], "Economy.currency_changed signal emitted on add_currency")
	assert_true(signal_data["balance"] == initial_balance + 500, "Economy.currency_changed payload matched new balance %d" % (initial_balance + 500))
	
	Economy.currency_changed.disconnect(callback)

func test_try_spend_success() -> void:
	var initial_balance: int = Economy.currency
	var spend_amount: int = 200
	var signal_data: Dictionary = {"emitted": false}
	
	var callback = func(_amount: int):
		signal_data["emitted"] = true
		
	Economy.currency_changed.connect(callback)
	var success: bool = Economy.try_spend(spend_amount, "test purchase")
	
	assert_true(success == true, "Economy.try_spend(%d) returned true when balance was %d" % [spend_amount, initial_balance])
	assert_true(Economy.currency == initial_balance - spend_amount, "Economy.currency balance updated to %d" % (initial_balance - spend_amount))
	assert_true(signal_data["emitted"], "Economy.currency_changed signal emitted on successful spend")
	
	Economy.currency_changed.disconnect(callback)

func test_try_spend_failure() -> void:
	var initial_balance: int = Economy.currency
	var excessive_amount: int = initial_balance + 10000
	var signal_data: Dictionary = {"emitted": false}
	
	var callback = func(_amount: int):
		signal_data["emitted"] = true
		
	Economy.currency_changed.connect(callback)
	var success: bool = Economy.try_spend(excessive_amount, "excessive purchase")
	
	assert_true(success == false, "Economy.try_spend(%d) returned false when balance was %d" % [excessive_amount, initial_balance])
	assert_true(Economy.currency == initial_balance, "Economy.currency remained unchanged at %d" % initial_balance)
	assert_true(not signal_data["emitted"], "Economy.currency_changed signal was NOT emitted on failed spend")
	
	Economy.currency_changed.disconnect(callback)
