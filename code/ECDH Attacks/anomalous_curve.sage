def lift(P, E, p):
    # lift point P from old curve to a new curve
    Px, Py = map(ZZ, P.xy())
    for point in E.lift_x(Px, all=True):
         # take the matching one of the 2 points corresponding to this x on the p-adic curve
        _, y = map(ZZ, point.xy())
        if y % p == Py:
            return point


p = 82880337306360052550952380657384418102169134986290141696988204552000561657747
a = 26413685284385555604181540288021678971301314378522544469879270355650843743231
b = 10017655579196313780863100027113686719855502076415017585743221280232958057095
E = EllipticCurve(GF(p), [a, b])
G = E(37991937053350834320678619330546903567320901767090609881924528835279022654346,
      28947208718252880061735762506756351277969075978732800286053352115837132331595)
assert E.order() == p

private_key = 28153370716511608040616395150859085058202177279382452583684367923334520519740
P = private_key * G

# Lift the points to some new curve over p-adic numbers
E_adic = EllipticCurve(Qp(p), [a+p*13, b+p*37]) 
G = p * lift(G, E_adic, p)
P = p * lift(P, E_adic, p)

# Calculate discrete log
Gx, Gy = G.xy()
Px, Py = P.xy()
found_key = int(GF(p)((Px / Py) / (Gx / Gy)))
assert found_key == private_key
print("success!")

from Crypto.Util.number import long_to_bytes
print("The private key is:", long_to_bytes(found_key).decode())
