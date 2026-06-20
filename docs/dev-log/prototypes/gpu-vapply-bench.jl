# GPU control prototype — the dominant kernel of matrix-free genomic REML is the
# symmetric marker product  u = Wt * (Wt' v)  (apply V without forming the n x n G).
# Per AI-REML iteration this runs O(1) times for the solve plus a few for the trace
# terms, each O(n*m). It is a pure GEMV/GEMM against the n x m marker panel — the
# ideal target for a vendor-agnostic GPU offload (here Metal.jl on Apple Silicon;
# the same KernelAbstractions/GPUArrays pattern maps to CUDA/AMDGPU/oneAPI).
#
# Benchmarks CPU (BLAS) vs Metal GPU for u = Wt*(Wt'v) across sizes, and validates
# the GPU result against the CPU result. Standalone; deps: Metal, LinearAlgebra, Printf.
using LinearAlgebra, Printf, Random
BLAS.set_num_threads(Sys.CPU_THREADS)

gpu_ok = false
try
    @eval using Metal
    global gpu_ok = Metal.functional()
catch err
    @info "Metal unavailable" err
end
@printf("Metal functional: %s\n", gpu_ok)

bench(f, reps) = (f(); minimum(@elapsed(f()) for _ in 1:reps))

# u = W*(W' B), B has k columns (k=1: the single V-apply GEMV; k>1: multivariate /
# block-PCG / marker-scan RHS, where GPU arithmetic intensity is higher).
function run_case(n, m, k; reps = 5)
    Random.seed!(1)
    W = randn(Float32, n, m)            # Float32: GPU-native, ample for marker math
    B = randn(Float32, n, k)
    Wt = transpose(W)
    cpu(W, Wt, B) = W * (Wt * B)
    u_cpu = cpu(W, Wt, B)
    t_cpu = bench(() -> cpu(W, Wt, B), reps)
    if gpu_ok
        Wg = MtlArray(W); Bg = MtlArray(B); Wtg = transpose(Wg)
        gpu(Wg, Wtg, Bg) = (r = Wg * (Wtg * Bg); Metal.synchronize(); r)
        u_gpu = Array(gpu(Wg, Wtg, Bg))
        t_gpu = bench(() -> gpu(Wg, Wtg, Bg), reps)
        rel = norm(u_gpu .- u_cpu) / norm(u_cpu)
        @printf("  n=%-7d m=%-5d k=%-3d  t_cpu=%.4fs  t_gpu=%.4fs  speedup=%.2fx  rel_err=%.2e\n",
                n, m, k, t_cpu, t_gpu, t_cpu / t_gpu, rel)
    else
        @printf("  n=%-7d m=%-5d k=%-3d  t_cpu=%.4fs  (no GPU)\n", n, m, k, t_cpu)
    end
    flush(stdout)
end

println("=== GPU control: u = W*(W' B), CPU(BLAS) vs Metal — GEMV (k=1) and GEMM (k>1) ===")
for k in (1, 8, 32, 64)
    run_case(100000, 3000, k)
end
println("--- fixed k=32, scaling n ---")
for n in (20000, 50000, 100000, 200000)
    run_case(n, 3000, 32)
end
println("DONE.")
