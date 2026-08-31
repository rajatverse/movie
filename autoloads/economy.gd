class_name Economy
extends Node

signal currency_changed(new_amount: int)

var currency: int = 1000

func add_currency(amount: int) -> void:
	currency += amount
	print("Added currency: %d. New balance: %d" % [amount, currency])
	currency_changed.emit(currency)

func try_spend(amount: int, reason: String = "") -> bool:
	if currency < amount:
		print("Spend failed! Tried to spend %d%s but currency is %d." % [amount, (" for '%s'" % reason) if reason != "" else "", currency])
		return false
	
	currency -= amount
	print("Spend successful! Spent %d%s. Remaining balance: %d." % [amount, (" for '%s'" % reason) if reason != "" else "", currency])
	currency_changed.emit(currency)
	return true
