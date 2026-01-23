from Crypto.Util.number import *
from collections import Counter
from tqdm import tqdm
import sage.parallel.multiprocessing_sage
from multiprocessing import Pool, cpu_count
from ptrlib import *
from subprocess import check_output

io = Socket("nc 153.125.146.243 5000")
print(io.recvline())
print(io.recvline())
ha = io.recvline().decode()
print(ha)
inp = input("hash >")
io.sendline(inp)
print(io.recvline())
print(io.recvline())
print(io.recvline())
print(io.recvline())


ct1_j = int(io.recvline().decode().split(": ")[1])
ct2_j = int(io.recvline().decode().split(": ")[1])

p = 4718527636420634963510517639104032245020751875124852984607896548322460032828353
j = 4667843869135885176787716797518107956781705418815411062878894329223922615150642

DBMP = ClassicalModularPolynomialDatabase()


class Volcano:

    def __init__(self, p, j):
        self.p = p
        self.j = j
        self.t = EllipticCurve(GF(p), j=self.j).trace_of_frobenius()
        self.ecc_core_param()

    def ecc_core_param(self):
        V = factor(self.p - self.t ^ 2, limit=2**20)
        self.v = [(pi, e // 2) for pi, e in V if e % 2 == 0]

    def moduler_polynomial(self, j):
        f = DBMP[self.l]
        Z.<X> = PolynomialRing(GF(p))
        return f(X, j).roots()

    def find_crutor_path(self, Path):
        for _ in range(256):
            re = self.moduler_polynomial(Path[-1])
            if len(re) == 1:
                return Path
            for new_j in re:
                if new_j[0] != Path[-2]:
                    Path.append(new_j[0])
                    break
            else:
                exit()

    def true_path(self, j):
        Paths = [[j, node[0]] for node in self.moduler_polynomial(j)]
        # v = list(sage.parallel.multiprocessing_sage.parallel_iter(2, f, [((2,), {}), ((3,),{})]))
        # v.sort(); v
        with Pool(cpu_count()) as pool:
            ret_path = [results for results in pool.imap_unordered(self.find_crutor_path, Paths)]
            return Counter([len(reti) - 1 for reti in ret_path]).most_common()[0][0]

    def up(self, l, j):
        self.l = l
        now = [j]
        depth = self.true_path(j)

        for _ in tqdm(range(128)):
            for new_j, _ in self.moduler_polynomial(j):
                if depth + 1 == self.true_path(new_j):
                    now.extend([new_j])
                    j = new_j
                    break
            else:
                print("crutor found")
                return now[::-1]
            depth += 1
            print()

    def find_path(self, l, start_j, end_j):
        # j -> start j
        path_start = self.up(l, start_j)
        # j -> end j
        path_end = self.up(l, end_j)
        
        print(path_start, path_end)
        path = path_start[1:][::-1] + path_end        
        return path

    def moduler_to_kernel(self, path, l):

        E = EllipticCurve(GF(p), j=path[0])

        choiced = []

        for path_i in path[1:]:
            for R in (Rs := E.isogenies_prime_degree(l)):
                if (_E := R.codomain()).j_invariant() == path_i:
                    E = _E
                    choiced.append(Rs.index(R))
                    break
            else:
                print("not find")
                exit()
        return choiced


vol = Volcano(p, j)

path = vol.find_path(2,ct1_j, ct2_j)
path2 = vol.moduler_to_kernel(path, 2)

io.sendline(str(path2)[1:-1])
io.sh()
