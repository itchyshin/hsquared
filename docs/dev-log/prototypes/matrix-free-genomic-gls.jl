# Matrix-free GENOMIC GLS — the regime where matrix-free actually wins.
# Genomic relationship G = W W' / m (dense, n x n). The current engine path forms
# G (n^2) and factorizes (O(n^3)). Matrix-free applies V = sa2*G + se2*I as
# V*v = sa2 * W*(W'v)/m + se2*v  (O(n*m), never forms G), solves V^-1 by PCG.
# Validates the GLS solution against the dense Cholesky path and benchmarks scaling.
using LinearAlgebra, Random, Printf
BLAS.set_num_threads(Sys.CPU_THREADS)

function make_genomic(n, m; sa2 = 0.6, se2 = 1.0, seed = 1)
    Random.seed!(seed)
    p = 0.05 .+ 0.9 .* rand(m)                 # allele freqs
    W = Matrix{Float64}(undef, n, m)
    @inbounds for j in 1:m
        pj = p[j]; c = 2pj; s = sqrt(2pj*(1-pj) + 1e-9)
        for i in 1:n
            g = (rand() < pj) + (rand() < pj)
            W[i, j] = (g - c) / s                # centered + scaled markers
        end
    end
    # true breeding values from marker effects, plus residual
    a = randn(m) .* sqrt(sa2 / m)
    y = 3.0 .+ W * a .+ sqrt(se2) .* randn(n)
    X = ones(n, 1)
    return (; y, X, W, m)
end

# Matrix-free V*v = sa2 * W*(W'v)/m + se2*v
applyV(v, W, m, sa2, se2) = sa2 .* (W * (transpose(W) * v) ./ m) .+ se2 .* v

# Jacobi preconditioner: diag(V) = sa2*diag(G) + se2 ; diag(G)_i = ||W_i||^2/m
function vdiag(W, m, sa2, se2)
    d = vec(sum(abs2, W; dims = 2)) ./ m
    return sa2 .* d .+ se2
end

# PCG for V x = b (V SPD), in-place, BLAS matvecs.
function pcg_V(W, m, sa2, se2, b, Minv; tol = 1e-10, maxit = 1000)
    x = zeros(length(b)); r = copy(b); z = Minv .* r; p = copy(z)
    rz = dot(r, z); bnrm = norm(b); its = 0
    for it in 1:maxit
        its = it
        Ap = applyV(p, W, m, sa2, se2)
        a = rz / dot(p, Ap)
        @. x += a * p
        @. r -= a * Ap
        norm(r)/bnrm < tol && break
        @. z = Minv * r
        rz1 = dot(r, z)
        @. p = z + (rz1/rz) * p
        rz = rz1
    end
    return x, its
end

# GLS via matrix-free V^-1 (PCG): beta = (X'V^-1 X)^-1 X'V^-1 y
function gls_matfree(prob, sa2, se2)
    W, m, X, y = prob.W, prob.m, prob.X, prob.y
    Minv = vdiag(W, m, sa2, se2) .^ -1
    Viy, i1 = pcg_V(W, m, sa2, se2, y, Minv)
    ViX = similar(X)
    its = i1
    for k in 1:size(X, 2)
        col, ik = pcg_V(W, m, sa2, se2, X[:, k], Minv)
        ViX[:, k] = col; its = max(its, ik)
    end
    XtViX = transpose(X) * ViX
    beta = XtViX \ (transpose(X) * Viy)
    return beta, its
end

function gls_dense(prob, sa2, se2)
    W, m, X, y = prob.W, prob.m, prob.X, prob.y
    G = (W * transpose(W)) ./ m            # n x n DENSE
    V = sa2 .* G + se2 * I
    F = cholesky(Symmetric(Matrix(V)))
    Viy = F \ y; ViX = F \ X
    beta = (transpose(X) * ViX) \ (transpose(X) * Viy)
    return beta
end

function run_case(n, m; sa2 = 0.6, se2 = 1.0, do_dense = true)
    prob = make_genomic(n, m; sa2, se2)
    b_mf, its = gls_matfree(prob, sa2, se2)
    t_mf = @elapsed gls_matfree(prob, sa2, se2)
    if do_dense
        b_d = gls_dense(prob, sa2, se2)
        t_d = @elapsed gls_dense(prob, sa2, se2)
        rel = abs(b_mf[1] - b_d[1]) / abs(b_d[1])
        @printf("n=%-7d m=%-5d  PCG its=%-4d  beta_relerr=%.2e  t_matfree=%.3fs  t_dense=%.3fs  speedup=%.1fx\n",
                n, m, its, rel, t_mf, t_d, t_d/t_mf)
        flush(stdout); return rel
    else
        @printf("n=%-7d m=%-5d  PCG its=%-4d  t_matfree=%.3fs  (dense skipped: G=%.1f GB infeasible)\n",
                n, m, its, t_mf, n^2 * 8 / 1e9)
        flush(stdout); return 0.0
    end
end

function main()
    println("=== matrix-free GENOMIC GLS: validation vs dense G + scaling ===")
    flush(stdout)
    me = 0.0
    me = max(me, run_case(2000, 2000))
    me = max(me, run_case(5000, 2000))
    me = max(me, run_case(12000, 2000))
    run_case(40000, 2000; do_dense = false)
    @printf("\nMAX beta rel_err (validated): %.2e  (PASS if < 1e-6)\n", me)
    flush(stdout)
end
main()
