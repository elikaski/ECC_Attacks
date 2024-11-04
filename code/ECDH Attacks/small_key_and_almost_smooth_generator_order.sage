p = 88664572752015126127869404674421545790506871948117527783533589813159111825511
a = 13
b = 37
E = EllipticCurve(GF(p), [a,b])
G = E(19374976316789648652022260955836934561553454311144967863145605756652014623129,
      68630819472054489323664324766002023315775509214344811025345735680440707888471)
n = G.order()

print("Number of bits in n:", n.nbits())
factors = n.factor()
print("n's factors:", factors)

PRIVATE_KEY_BIT_SIZE = 64
import random
private_key = random.randrange(2^PRIVATE_KEY_BIT_SIZE)
P = private_key * G

print("We know that the private key is", PRIVATE_KEY_BIT_SIZE, "bits long")
print("Lets find which of the factors of G's order are relevant for finding the private key")
# find factors needed such that the order is greater than the secret key size
count_factors_needed = 0
new_order = 1
for p, e in factors:
    new_order *= p^e
    count_factors_needed += 1
    if new_order.nbits() >= PRIVATE_KEY_BIT_SIZE:
        print("Found enough factors! The rest are not needed")
        break
factors = factors[:count_factors_needed]
print("Considering these factors:", factors)

print("Calculating discrete log for each quotient group...")
subsolutions = []
subgroup = []
for p, e in factors:
    quotient_n = (n // p ^ e)
    G0 = quotient_n * G # G0's order is p^e
    P0 = quotient_n * P
    k = G0.discrete_log(P0)
    subsolutions.append(k)
    subgroup.append(p ^ e) # k the order of G0

print("Running CRT...")
found_key = crt(subsolutions, subgroup)
assert found_key * G == P
assert private_key == found_key
print("success!")
