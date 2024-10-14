extends Node

# Constructor class for numberlike objects.

func rational(num, den):
	if num is int: num = Integer.new(str(num))
	if num is String: num = Integer.new(num)
	if den is int: den = Integer.new(str(den))
	if den is String: den = Integer.new(den)
	assert(num is Integer); assert(den is Integer)
	return Rational.new(num, den)

func rational_from_string(s: String):
	if s.count("/") != 1:
		return null 
	var split = s.replace(" ", "").split("/") 
	return rational(split[0], split[1])

func interval_from_string(s: String):
	var rfs = rational_from_string(s)
	if rfs != null:
		return interval_from_rational(rfs)
	return null

func interval_from_rational(rat: Rational):
	var rat_factors = factor_rational(rat)
	print(rat_factors["residue"])
	return Interval.new(rat_factors["factors"], rat_factors["residue"], 1.0)

func interval_from_cents():
	pass
	
func interval_from_vector():
	pass

# method for factoring numbers into vector-residue pairs

func factor_rational(rat: Rational):
	var nf = rat.numerator.factor(); var df = rat.denominator.factor()
	var nffs = nf["factors"]; var dffs = df["factors"]
	var f = Dictionary()
	
	var total_primes = nffs.keys() + dffs.keys()
	for p in total_primes:
		if p in nffs.keys():
			f[p] = nffs[p]
		else:
			f[p] = -dffs[p]
	return {"factors": f, "residue": rational(nf["residue"], df["residue"])}
