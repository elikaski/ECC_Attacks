p = 682209701131405092329016993551
a = -35
b = 98
E = EllipticCurve(GF(p), [a, b])
G = E(516365702870683577608927237052, 
      524474557735717484100814381066)

# Find embedding degree k
Gn = G.order()
k = 1
while p^k % Gn != 1:
    k += 1
print("Found k:", k)

# Select private key, and calculate public key Q
private_key = 5072587499125503347
Q = private_key * G

# Define new curve mod p^k and the points on it
Ek = EllipticCurve(GF(p ^ k), [a, b])
Gk = Ek(G)
Qk = Ek(Q)
Rk = Ek.random_point()

# Find a point T with order d such that d divides G's order
m = Rk.order()
d = gcd(m, Gn)
Tk = (m // d) * Rk
assert Tk.order() == d
assert (Gn*Tk).is_zero() # Point INFINITY

# Using T, pair G and Q to integers g and q such that q=g^n (mod p^k)
g = Gk.weil_pairing(Tk, Gn)
q = Qk.weil_pairing(Tk, Gn)
# Alternatively:
#g = Gk.tate_pairing(Tk, Gn, k)
#q = Qk.tate_pairing(Tk, Gn, k)

# Make sure the pairing did not break anything
assert g ^ private_key == q

print("Calculating private key...")
found_key = q.log(g)
assert found_key == private_key
print("success!")

from Crypto.Util.number import long_to_bytes
print("The private key is:", long_to_bytes(found_key).decode())
