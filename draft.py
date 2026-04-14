def smul (n, L):
    for i in range(len(L)):
        print(L[i])
        L[i] = L[i] * n 
        print(L[i])
    
    return(L)

L = [1,2,3]
M=[4,5,6]
C = [1,2]
#print(smul(2,L))

def vsom(L, M):
    assert len(L) == len(M), "Patatemamon"
    res = []
    for i in range(len(L)):
        res.append(L[i]+M[i])
    return res

def vdiff(L, M):
    assert len(L) == len(M), "Patatemamon"
    res = []
    for i in range(len(L)):
        res.append(L[i]-M[i])
    return res

print(vsom(L, M))
print(vdiff(L, M))
print(vsom(L, C))