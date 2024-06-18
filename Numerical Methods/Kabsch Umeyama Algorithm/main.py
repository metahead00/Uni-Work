#Name & Surname: Melike Besparmak
#Student ID: 150220061

import numpy as np
import matplotlib.pyplot as plt
import sys

def create_matrix(arg):
    file = open(arg, 'r')
    matrix = []
    with file as file:
        data = file.readlines()
        for line in data:
            entry = [float(value) for value in line.split()]
            matrix.append(entry)
    matrix = np.array(matrix)
    return matrix   

def manual_qr_and_svd(A):
    Q, _ = qr(A @ A.T)
    V = Q # left-singular vectors

    sorted_eigvals = eigvals_qr(A @ A.T)
    Sigma = np.sqrt(sorted_eigvals)
    Sigma = np.diag(Sigma) # singular values in descending order

    inv_s = np.where(Sigma != 0, 1 / Sigma, 0)  # inverse of a diagonal matrix 
    Vt = inv_s @ V.T @ A # compute V -> right-singular vectors
    Vt_normalized = np.apply_along_axis(lambda v: v / np.linalg.norm(v), axis=0, arr=Vt) # normalize v

    return V, Sigma, Vt_normalized

def qr(A): # using gram-schmidt
    n, m = A.shape 

    Q = np.empty((n, n))
    u = np.empty((n, n))

    u[:, 0] = A[:, 0]
    Q[:, 0] = u[:, 0] / np.linalg.norm(u[:, 0])

    for i in range(1, n):
        u[:, i] = A[:, i]
        for j in range(i):
            u[:, i] -= (A[:, i] @ Q[:, j]) * Q[:, j] # get each u vector

        Q[:, i] = u[:, i] / np.linalg.norm(u[:, i]) # compute each e vetor

    R = np.zeros((n, m))
    for i in range(n):
        for j in range(i, m):
            R[i, j] = A[:, j] @ Q[:, i]

    return Q, R

def eigvals_qr(A, tol=1e-12, maxiter=10000):
    A_old = A
    A_new = A

    diff = np.inf
    i = 0
    while (diff > tol) and (i < maxiter):
        A_old[:, :] = A_new
        Q, R = qr(A_old)

        A_new[:, :] = R @ Q

        diff = np.abs(A_new - A_old).max()
        i += 1

    eigvals = np.diag(A_new)
    sorted_eigvals = -np.sort(-eigvals)  # eigenvalues in descending order

    return sorted_eigvals

def plot(A):
    x_coords = A[:, 0]  # First column (x-coordinates)
    y_coords = A[:, 1]  # Second column (y-coordinates)
    z_coords = A[:, 2]  # Third column (z-coordinates)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')  # Create a 3D axis
    ax.scatter(x_coords, y_coords, z_coords, color='purple')

    ax.set_xlabel('X-axis')  
    ax.set_ylabel('Y-axis') 
    ax.set_zlabel('Z-axis') 

    plt.show()  

mat1 = create_matrix(sys.argv[1])	
mat2 = create_matrix(sys.argv[2])	
corres_mat = create_matrix(sys.argv[3])

new_mat1 = []
new_mat2 = []
for row in corres_mat:
    new_mat1.append(mat1[int(row[0])])
    new_mat2.append(mat2[int(row[1])])

new_mat1 = np.array(new_mat1)
new_mat2 = np.array(new_mat2)

centroid_Q = np.mean(new_mat1, axis=0)
centroid_P = np.mean(new_mat2, axis=0)

Q = np.array(new_mat1 - centroid_Q)
P = np.array(new_mat2 - centroid_P)

covar_mat = Q.T @ P

# using manual qr and manual svd
v, _, w = manual_qr_and_svd(covar_mat) 
ref = np.linalg.det(v @ w.T)
s = np.array([[1,0,0], [0,1,0], [0,0,ref]]) # change according to reflection

rot_mat = w.T @ s @ v.T
np.savetxt('rotation_mat.txt', rot_mat)

trans_vec = centroid_P - rot_mat @ centroid_Q
trans_mat = np.tile(trans_vec.reshape((3, 1)), (1, mat2.shape[0]))
np.savetxt('translation_vec.txt', trans_mat)

# inverse rotation
newQ = np.linalg.inv(rot_mat) @ (mat2.T - trans_mat)

for row in corres_mat:
    np.delete(newQ.T, int(row[1]))

merged = np.concatenate((newQ.T, mat1), axis=0)
np.savetxt('merged.txt', merged)
plot(merged)
