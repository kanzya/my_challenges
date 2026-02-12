from ptrlib import *


io = Socket("localhost 9999")
p = int(io.recvlineafter(b": "))

io.sendline(p-1)

io.sh()