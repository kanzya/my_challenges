from ptrlib import *


def le_bytes_to_num(byte) -> int:
    res = 0
    for i in range(len(byte) - 1, -1, -1):
        res <<= 8
        res += byte[i]
    return res


def num_to_16_le_bytes(num: int) -> bytes:
    res = []
    for i in range(16):
        res.append(num & 0xff)
        num >>= 8
    return bytes(res)


def num_to_8_le_bytes(num: int) -> bytes:
    return struct.pack('<Q', num)


p = 2**130 - 5

# sock = Process(["python3", "chal.py"])
sock = Socket("localhost 5000")

target = bytes.fromhex(sock.recvlineafter("my SPECIAL_MIND is ").strip().decode())
ct0 = bytes.fromhex(sock.recvlineafter(b"= ").strip().decode())
t0  = bytes.fromhex(sock.recvlineafter(b"= ").strip().decode())

ts = []
n = 80
for _ in range(n):
    sock.sendlineafter("what is your mind: ", "need")
    t = bytes.fromhex(sock.recvlineafter(b"my MIND was ").strip().decode())
    ts.append(le_bytes_to_num(t))

mat = [[0] * (n - 1) for _ in range(n)]
for i in range(n - 1):
    mat[0][i] = ts[0] - ts[i + 1]
    mat[i + 1][i] = p

res = matrix(ZZ, mat).LLL()
print([int(v).bit_length() for v in res[1]])

x = int(res[1][0])
t = ts[0] - ts[1]
r2 = int(x * pow(t, -1, p) % p)
print(r2)  # alpha(small)*r^(-2)

for alpha in range(-64, 64):
    v = pow(r2, -1, p) * alpha % p
    if alpha == 0:
        continue
    if not GF(p)(v).is_square():
        continue
    r = int(GF(p)(v).sqrt())
    if r < 2**128 and (r & 0x0ffffffc0ffffffc0ffffffc0fffffff) == r:
        print(alpha, r)
        break
    r = p - r
    if r < 2**128 and (r & 0x0ffffffc0ffffffc0ffffffc0fffffff) == r:
        print(alpha, r)
        break
else:
    print("not found")
    exit()

c0 = le_bytes_to_num((num_to_8_le_bytes(0) + num_to_8_le_bytes(16)))
s = (le_bytes_to_num(t0) - (le_bytes_to_num(ct0 + b"\x01") * r ^ 2 + c0 * r) % p) % (2**128)
target = le_bytes_to_num(target)
for k in range(4):
    cr = (2**128) * k + (target - s) % (2**128)
    c = (cr - c0 * r) * pow(r, -2, p) % p
    if 2**128 <= c < 2**129:
        inp = xor(ct0, num_to_16_le_bytes(int(c - 2**128)))
        sock.sendline(inp.hex())
        sock.interactive()
