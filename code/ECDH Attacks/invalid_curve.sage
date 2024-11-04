from ecdsa.ecdsa import generator_128r1, curve_128r1
from Crypto.Util.number import long_to_bytes
from Crypto.Util.Padding import pad, unpad
from Crypto.Cipher import AES
import random


# Select a curve and generator
curve = curve_128r1
G = generator_128r1
n = G.order()
p = curve.p()
a = curve.a()

# This is the private key of the other side, we don't know it and don't use it!
private_key = random.randrange(n)


# Both sides encrypt and decrypt data the same way
# key is the shared point's x coordinate, IV is point's y coordinate
def encrypt_data(shared_point, message):
    if shared_point.is_zero():
        x, y = 0, 0
    else:
        x, y = shared_point.xy()
    key = long_to_bytes(int(x)).rjust(16, b"\x00")
    iv = long_to_bytes(int(y)).rjust(16, b"\x00")
    cipher = AES.new(key, AES.MODE_CBC, iv)

    message = pad(message.encode(), 16)
    return cipher.encrypt(message)


def decrypt_data(shared_point, enc_message):
    if shared_point.is_zero():
        x, y = 0, 0
    else:
        x, y = shared_point.xy()
    key = long_to_bytes(int(x)).rjust(16, b"\x00")
    iv = long_to_bytes(int(y)).rjust(16, b"\x00")
    cipher = AES.new(key, AES.MODE_CBC, iv)

    decrypted = cipher.decrypt(enc_message)
    return unpad(decrypted, 16)


def ECDH(A):
    # Send our public key to the other side
    # Have them reach the shared point and
    # Send us an encrypted message using the shared point as key

    # This part takes place remotely and is unknown to the attacker
    shared_point = private_key * A
    message = "Inconceivable!"
    return encrypt_data(shared_point, message)


def brute_force_encrypted_message(A, encrypted_message, max_order):
    # Returns n such that n*A matches the key used to encrypt the message
    for i in range(1, max_order):
        shared_point = i * A
        try:
            # If both padding is correct and all characters are ascii
            # Then it is probably the correct encryption key
            decrypted = decrypt_data(shared_point, encrypted_message)
            decrypted = decrypted.decode()
            return i
        except:
            continue
    raise Exception("Did not find a value for one of the encrypted messages")


def find_curves_with_small_subgroup(p, a, max_order):
    # Yield tuples of (order, point) such that the point is
    # on a curve with the same a & p values, but different b
    # and the point's order is <= max_order
    orders_found = set()
    b = 0
    while True:
        b += 1
        if b == p:
            # Ran out of b values
            break
        if (4*a^3 + 27*b^2) % p == 0:
            # Curve is singular
            continue

        E = EllipticCurve(GF(p), [a, b])
        for _ in range(100):
            R = E.random_point()
            n = R.order()
            for f, e in n.factor():
                if f in orders_found:
                    continue
                if f > max_order:
                    break

                # Create a point with order f
                orders_found.add(f)
                P = (n // f) * R
                assert P.order() == f
                yield (f, P)


subsolutions = []
subgroup = []
max_order = 10000
upto = 1
for order, A in find_curves_with_small_subgroup(p, a, max_order):
    upto *= order
    print("Found point with order", order, "so now can find keys of size up to", upto)

    # Send this point as our public key and get an encrypted message from other side
    encrypted_message = ECDH(A)

    # Find the value n such that: private_key = n (mod order)
    key_mod_order = brute_force_encrypted_message(A, encrypted_message, max_order)

    # Save result to be used in CRT later
    subsolutions.append(key_mod_order)
    subgroup.append(order)

    # Found enough values to calculate private key
    if upto >= n:
        break

print("Found enough values! Running CRT...")
found_key = crt(subsolutions, subgroup)
print("Found private key", found_key)
assert private_key == found_key
print("success!")