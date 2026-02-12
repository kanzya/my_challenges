from Crypto.Util.number import *
from hashlib import *
from params import modulus
import os

FLAG = os.getenv("FLAG", "flag{Doumo!_Yukkuri_Reimu_to_Yukkuri_Marisa_Daze!!!!!!!!}").encode()
FLAG += sha224(FLAG).hexdigest().encode()

def bxor(a,b):
    return bytes([_a ^^ _b for _a, _b in zip(a,b)])

def enc(m):
    F.<t> =GF(2^61, modulus=modulus)
    ret = 0
    t = F.random_element()
    poly = t
    for i in range(len(m)*8):
        poly *= t
        ret  <<= 1
        ret  += int(str(poly[8]))
    return bxor(long_to_bytes(ret), m)

print("Doumo!_Yukkuri_Reimu_to_Yukkuri_Marisa_Daze!!!!!!")
print(enc(FLAG))
