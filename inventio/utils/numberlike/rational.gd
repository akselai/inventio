class_name Rational extends Object

var numerator = Integer.new("1")
var denominator = Integer.new("1")

func _init(num, den):
	assert(num is Integer)
	numerator = num; denominator = den
	
func equal(right: Rational):
	return numerator == right.numerator and denominator == right.denominator

func mul(right: Rational):
	var a = numerator.mul(right.numerator)
	var b = denominator.mul(right.denominator)
	var d = a.gcd(b)
	
	return Rational.new(a.div(d), b.div(d))

func div(right: Rational):
	var a = numerator.mul(right.denominator)
	var b = denominator.mul(right.numerator)
	var d = a.gcd(b)
	return Rational.new(a.div(d), b.div(d))

func _to_string():
	return str(numerator) + "/" + str(denominator)
