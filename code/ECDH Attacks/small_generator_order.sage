import random
p = random_prime(2^32)
a = random.randrange(p)
b = random.randrange(p)
E = EllipticCurve(GF(p), [a,b])
G = E.gens()[0]
n = G.order()
private_key = random.randrange(n)
A = private_key * G
found_key = G.discrete_log(A)
assert found_key * G == A
assert private_key == found_key
print("success!")
