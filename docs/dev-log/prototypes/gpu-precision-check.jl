# Which side is wrong at k>=32?  Compare CPU-Float32 and Metal-Float32 against a
# CPU-Float64 ground truth for u = W*(W'B). Apple GPUs have no Float64, so the test
# is: is the ~3% gap reduced-precision Metal GEMM, or just Float32 reduction depth?
using LinearAlgebra, Printf, Random
try; @eval using Metal; catch; end
Random.seed!(1)
for (n, m, k) in ((100000, 3000, 8), (100000, 3000, 32), (100000, 3000, 64))
    W64 = randn(n, m); B64 = randn(n, k)
    ref = W64 * (transpose(W64) * B64)                 # Float64 ground truth
    W32 = Float32.(W64); B32 = Float32.(B64)
    cpu32 = W32 * (transpose(W32) * B32)
    e_cpu = norm(Float64.(cpu32) .- ref) / norm(ref)
    Wg = MtlArray(W32); Bg = MtlArray(B32)
    gpu32 = Array(Wg * (transpose(Wg) * Bg)); Metal.synchronize()
    e_gpu = norm(Float64.(gpu32) .- ref) / norm(ref)
    @printf("n=%d m=%d k=%-3d  rel_err vs Float64:  CPU-f32=%.2e   Metal-f32=%.2e\n",
            n, m, k, e_cpu, e_gpu)
end
