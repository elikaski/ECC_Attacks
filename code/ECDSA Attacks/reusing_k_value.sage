from ecdsa.ecdsa import curve_256, generator_256, Public_key, Private_key
from Crypto.Util.number import bytes_to_long,  long_to_bytes
from hashlib import sha256
import random

# Select a curve and generator
curve = curve_256
generator = generator_256
n = generator.order()

# Create private key and public keys
secret_key = 6743529130774090927928101169617481154782309
public_key = Public_key(generator, generator * secret_key)
private_key = Private_key(public_key, secret_key)

# Sign 2 messages using the same k
k = random.randrange(curve.p())
message1 = "Life is like a box of chocolates."
message2 = "You never know what you're gonna get."
z1 = bytes_to_long(sha256(message1.encode()).digest())
z2 = bytes_to_long(sha256(message2.encode()).digest())

signature1 = private_key.sign(z1, k)
signature2 = private_key.sign(z2, k)

# Given the two messages and their signatures, find k
found_k = (z1 - z2) * inverse_mod(signature1.s - signature2.s, n) % n
assert k == found_k

# Given k and one of the messages, find the private key
found_key = inverse_mod(signature1.r, n) * (found_k * signature1.s - z1) % n
assert found_key == secret_key
print("success!")
print("The secret is:", long_to_bytes(found_key).decode())
