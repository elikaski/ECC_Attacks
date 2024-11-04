from ecdsa import SigningKey, NIST256p

signing_key = SigningKey.generate(NIST256p)
verifying_key = signing_key.verifying_key

class MyHash:
    def __init__(self, data):
        self.data = data

    def digest(self):
        return self.data

# Sign the message and verify the signature
message = "Please transfer 1,000$ to GitHub"
signature = signing_key.sign(message.encode(), hashfunc=MyHash)
assert verifying_key.verify(signature, message.encode(), hashfunc=MyHash)

# Construct an evil message and verify the original message's signature is valid for it as well
evil_message = "Please transfer 1,000$ to GitHub and 1,000,000$ to Eli Kaski"
assert verifying_key.verify(signature, evil_message.encode(), hashfunc=MyHash)
print("success!")
