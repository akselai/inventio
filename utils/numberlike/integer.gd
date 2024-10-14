class_name Integer extends Object

var value = "0"

func _init(val):
	if val is int: val = str(val)
	assert(val is String)
	value = val

func _to_string():
	return value

func add(right: Integer):
	return Integer.new(Integer_sum(value, right.value))
	
func sub(right: Integer):
	return Integer.new(Integer_diff(value, right.value))

func mul(right: Integer):
	return Integer.new(Integer_multiply(value, right.value))

func div(right: Integer):
	return Integer.new(Integer_qr(value, right.value)["quotient"])

func mod(right: Integer):
	return Integer.new(Integer_qr(value, right.value)["remainder"])
	
func gcd(right: Integer):
	return Integer.new(Integer_gcd(value, right.value)) 

func factor():
	return Integer_factor(value)

func equal(right: Integer):
	return Integer.new(Integer_equal(value, right.value))

func lessthan(right: Integer):
	return Integer.new(Integer_lessthan(value, right.value))

func unpad(str0: String):
	var result = str0.lstrip("0")
	return "0" if result == "" else result

func Integer_sum(str1, str2):
	if len(str1) > len(str2):
		return Integer_sum(str2, str1)
 
	var result = ""
	var n = len(str2)
	str1 = str1.pad_zeros(n); str2 = str2.pad_zeros(n)
	var carry = 0
 
	for i in range(n - 1, -1, -1):
		var sum_val = (int(str1[i]) - 0) + (int(str2[i]) - 0) + carry
		result = str(sum_val % 10 + 0) + result
		@warning_ignore("integer_division")
		carry = sum_val / 10
 
	if carry:
		result = str(carry + 0) + result
	
	return result

func Integer_diff(str1, str2):
	var result = ""
	var n = len(str1)
	str1 = str1.pad_zeros(n); str2 = str2.pad_zeros(n)
	var carry = 0
 
	for i in range(n - 1, -1, -1):
		var _sub = (int(str1[i]) - 0) - (int(str2[i]) - 0) - carry
 
		if _sub < 0:
			_sub += 10
			carry = 1
		else:
			carry = 0
 
		result = str(_sub + 0) + result
	
	return unpad(result)

func Integer_multiply(A, B):
	# Base case for small numbers: perform normal multiplication
	if len(A) < 10 or len(B) < 10:
		return str(int(A) * int(B))
 
	var n = max(len(A), len(B))
	var n2 = n / 2
 
	# Pad the numbers with leading zeros to make them equal in length
	A = A.pad_zeros(n)
	B = B.pad_zeros(n)
 
	# Split the numbers into halves
	var Al = A.left(n2); var Ar = A.right(len(A) - n2)
	var Bl = B.left(n2); var Br = B.right(len(A) - n2)
 
	# Recursively compute partial products and sum using Karatsuba algorithm
	var p = Integer_multiply(Al, Bl)
	var q = Integer_multiply(Ar, Br)
	var r = Integer_multiply(Integer_sum(Al, Ar), Integer_sum(Bl, Br))
	r = Integer_diff(r, Integer_sum(p, q))
 
	# Combine the partial products to get the final result
	return unpad(Integer_sum(Integer_sum(p + '0'.pad_zeros(n), r + '0'.pad_zeros(n2)), q))

func intermediate_qr(A, B):
	# divide when A < 10*B, returns divisor and remainder
	if Integer_lessthan(A, B):
		return {"quotient": "0", "remainder": A}
	for i in [9, 8, 7, 6, 5, 4, 3, 2, 1]:
		var multiple = Integer_multiply(B, str(i))
		if Integer_lessthan(multiple, A) or Integer_equal(multiple, A):
			return {"quotient": str(i), "remainder": Integer_diff(A, multiple)}
	
	return {"quotient": null, "remainder": null}
	
func Integer_qr(A, B):
	var ans = ""
	
	var i = 0
	var temp = str(A[i])
	if Integer_lessthan(A, B):
		return {"quotient": 0, "remainder": A}
	while Integer_lessthan(temp, B):
		temp = temp + str(A[i + 1])
		i += 1
	i += 1
	
	var qr = intermediate_qr(temp, B)
	while len(A) > i: 
		qr = intermediate_qr(temp, B)
		ans += qr["quotient"]
		temp = unpad(qr["remainder"] + A[i])
		i += 1
	
	# one more step
	qr = intermediate_qr(temp, B)
	ans += qr["quotient"]
	
	if len(ans) == 0: return "0"
	return {"quotient": ans, "remainder": qr["remainder"]} 

func Integer_gcd(A, B):
	return A if B == "0" else Integer_gcd(B, Integer_qr(A, B)["remainder"])

func Integer_equal(A, B):
	if len(A) < len(B): return false
	if len(A) > len(B): return false
	for i in range(len(A)):
		if int(A[i]) < int(B[i]): return false
		if int(A[i]) > int(B[i]): return false
	return true

func Integer_lessthan(A, B):
	if len(A) < len(B): return true
	if len(A) > len(B): return false
	for i in range(len(A)):
		if int(A[i]) < int(B[i]): return true
		if int(A[i]) > int(B[i]): return false
	return false

const primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]

func Integer_factor(n):
	var factors = Dictionary()
	for p in primes:
		var prime = str(p)
		while Integer_qr(n, prime)["remainder"] == "0":
			if p in factors.keys():
				factors[p] += 1
			else:
				factors[p] = 1
			n = Integer_qr(n, prime)["quotient"]
	return {"factors": factors, "residue": n}
