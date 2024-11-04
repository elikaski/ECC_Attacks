from ecdsa.ecdsa import generator_256
from Crypto.Util.number import bytes_to_long
from hashlib import sha256
import random


def hash_message(message):
    return bytes_to_long(sha256(message.encode()).digest())

def verify(public_key, G, message, r, s):
        n = G.order()
        if r < 1 or r > n - 1 or s < 1 or s > n-1:
            return False
        hash = hash_message(message)
        u1 = (hash * inverse_mod(s, n)) % n
        u2 = (r * inverse_mod(s, n)) % n
        P = u1 * G + u2 * public_key
        return P.x() % n == r

def sign(private_key, G, message):
    n = G.order()
    k = random.randrange(n)
    hash = hash_message(message)

    r = (k * G).x() % n
    s = inverse_mod(k, n) * (hash + r * private_key) % n
    return r, s


# Create private and public keys
G = generator_256
n = G.order()
private_key = random.randrange(n)
public_key = private_key * G

# Sign a message and verify it
message = "Let me be the one that shines with you"
r, s = sign(private_key, G, message)
assert verify(public_key, G, message, r, s)

# Create a fake private key and generator that match the original public key
x = random.randrange(n)
fake_G = x * public_key
fake_private_key = inverse_mod(x, n)
assert fake_private_key != private_key
assert fake_G != G

# Sign an evil message and verify it using the same public key
evil_message = "Where did I go wrong?"
r, s = sign(fake_private_key, fake_G, evil_message)
assert verify(public_key, fake_G, evil_message, r, s)
