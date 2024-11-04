from ecdsa.ecdsa import curve_256, generator_256, Public_key, Private_key
from Crypto.Util.number import bytes_to_long, long_to_bytes
from hashlib import sha1
import random


def build_matrix(signatures, bias, q):
    # M matrix should be:
    """
    [
            B 0   m'1 m'2 m'2 ... m'n
            0 B/q r'1 r'2 r'3 ... r'n
            0 0
            0 0        q * I
            0 0
    ]
    where:
        m' = s^-1 * m
        r' = s^-1 * r
    """

    # Construct the first 2 rows of M:
    row1 = [bias, 0]
    row2 = [0, bias / q]
    for m, r, s in signatures:
        row1.append((inverse_mod(s, q) * m) % q)
        row2.append((inverse_mod(s, q) * r) % q)
    top_rows = Matrix(QQ, [row1, row2])

    # Construct the q*I block along with 2 columns of zeros
    zero_cols = zero_matrix(QQ, len(signatures), 2)
    qI = q * identity_matrix(QQ, len(signatures))
    bottom_rows = block_matrix([[zero_cols, qI]])

    # Combine all rows into one matrix
    M = top_rows.stack(bottom_rows)
    return M


def find_private_key(L, signatures, public_key):
    # Check if any valid k was found in L
    generator = public_key.generator
    q = generator.order()
    for row in L.rows():
        for i in range(len(signatures)):
            m,r,s = signatures[i]
            # Skip the first two vector components we used to improve LLL
            possible_k = row[i+2]
            # LLL might have swapped the sign of the found short vectors
            for k in [possible_k, -possible_k]:
                d = inverse_mod(r,q)*(k*s-m) % q
                if d*generator == public_key.point:
                    return d


# Select a curve and generator
curve = curve_256
generator = generator_256
q = int(generator_256.order())

# Create private key and public key
secret_key = 1793056234309773077862125006843383726029262764680727851636
public_key = Public_key(generator, generator * secret_key)
private_key = Private_key(public_key, secret_key)

# Sign some messages
messages_to_sign = [
    "And then I go and spoil it all",
    "By saying somethin' stupid like",
    "I love you"
]

signatures = []
for message in messages_to_sign:
    message_hash = bytes_to_long(sha1(message.encode()).digest())
    k = bytes_to_long(sha1(long_to_bytes(random.randrange(q))).digest())
    signature = private_key.sign(message_hash, k)
    signatures.append((message_hash, signature.r, signature.s))

# Given the messages and their signatures, retrieve the private key

# Build the matrix out of the signatures
# We know that k < 2^160 because it is the result of sha1
bias = 2^160
M = build_matrix(signatures, bias, q)

# Calculate the closest short vector
L = M.LLL()

# Find the private key!
found_key = find_private_key(L, signatures, public_key)
assert found_key == secret_key
print("success!")
print("The secret is:", long_to_bytes(found_key).decode())
