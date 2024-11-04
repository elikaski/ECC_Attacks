p = 183740305291166889900894879302858411333
a = 13
b = 37
E = EllipticCurve(GF(p), [a,b])
G = E(123764810000715262449972298016641419881,
144640915410606177233842123838934486566)
n = G.order()
print("number of bits in n:", n.nbits())
print("n's factors:", n.factor())
print("number of bits in n's greatest factor:", n.factor()[-1][0].nbits())
import random
private_key = random.randrange(n)
A = private_key * G
print("Calculating discrete_log...")
found_key = G.discrete_log(A)
assert found_key * G == A
assert private_key == found_key
print("success!")
