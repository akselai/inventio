extends Node

func snap_to_array(x, array): # array needs to be sorted
	var ind = array.bsearch(x, true)
	if ind == 0:
		return array[0]
	if ind == len(array):
		return array[-1]
	if abs(x - array[ind-1]) < abs(x - array[ind]):
		return array[ind-1]
	else:
		return array[ind]

func snap_to_scale(x, scale_):
	var scale_1 = scale_.duplicate()
	scale_1.push_front(0)
	var num_equave = floor(x / scale_1[-1])
	x = fmod(x, scale_1[-1])
	return snap_to_array(x, scale_1) + scale_1[-1] * num_equave
	
func array_unique(array: Array) -> Array: # unique elements in an array
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func from_rational(alpha: Rational):
	var f = alpha.factor()
	var vector = f["factors"].duplicate(true); 
	var fractional_residue = f["residue"];
	var real_residue = 1.0
	return Interval.new(vector, fractional_residue, real_residue)

# pollard rho for 62-bit numbers (don't make me use this ever)
'''
func gcd(m, n): return (m if n == 0 else gcd(n, m % n))

func small_mod_multiply(m, n, p):
	var result = 0
	var current = m
	while n:
		if n & 1:
			result = (result + current) % p
		current = 2 * current % p
		n >>= 1
	return result

func pollard_step(n, p):
	# n squared plus one
	var n0 = small_mod_multiply(n, n, p) + 1
	return n0

func pollard_factor(n):
	if not(n is int) or n >= 4611686018427387904:
		return null
	var x = 2; var y = x; var d = 1
	while d == 1:
		x = pollard_step(x, n); y = pollard_step(pollard_step(y, n), n)
		d = gcd(abs(x - y), n)
	return d
'''
