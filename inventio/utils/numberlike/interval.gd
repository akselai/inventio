class_name Interval extends Resource

var vector = Dictionary() # keys are formal primes
var fractional_residue = Construct.rational_from_string("1/1")
var real_residue = 1.0

func _to_string():
	var str1 = ""
	var str2 = ""
	var primes = vector.keys(); primes.sort()
	
	for p in primes:
		str1 = str1 + str(p) + "."
		str2 += str(vector[p]) + " "
	
	var str3 = "" 
	if fractional_residue.equal(Construct.rational_from_string("1/1")):
		str3 = " × " + str(fractional_residue)
	return str1.trim_suffix(".") + " [" + str2.trim_suffix(" ") + ">" + str3

func _init(vector_, fractional_residue_, real_residue_):
	vector = vector_; fractional_residue = fractional_residue_; real_residue = real_residue_

func value(): # value in float
	for p in vector.keys():
		print(p**vector[p])
