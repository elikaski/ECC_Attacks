p = 102360775616927576983385464260307534406913988994641083488371841417601237589487
a = -3
b = 2
assert (4*a^3 + 27*b^2) % p == 0

Gx = 1777671135698746847568710125129424132255529153914112337834835240247819869964
Gy = 6786424314307625790108882554225666781375821855884993473586521771737454762217
Qx = 45541468695354471317248123146376609839909398850045396377931300808635064950836
Qy = 42191909885728105279718027025083923092282618497451601162405594991792376530066

x = GF(p)["x"].gen()
f = x^3 + a*x + b
roots = f.roots()

assert len(roots) == 2 # two roots, so one must be double
if roots[0][1] == 2:
    double_root = roots[0][0]
    single_root = roots[1][0]
else:
    double_root = roots[1][0]
    single_root = roots[0][0]

print("double root:", double_root)
print("single root:", single_root)

# map G and Q to the new "shifted" curve
Gx = (Gx - double_root)
Qx = (Qx - double_root)

# Transform G and Q into numbers g and q, such that q=g^n
t = double_root - single_root
t_sqrt = t.square_root()

def transform(x, y, t_sqrt):
    return (y + t_sqrt * x) / (y - t_sqrt * x)

g = transform(Gx, Gy, t_sqrt)
q = transform(Qx, Qy, t_sqrt)
print("g:", g)
print("q:", q)

# Find the private key n
print("Factors of p-1:", factor(p-1))
print("Calculating discrete log for g and q...")
found_key = discrete_log(q, g)
print("Found private key:", found_key)

from Crypto.Util.number import long_to_bytes
print("The secret is:", long_to_bytes(found_key).decode())
