import "mk-datasets"
import "kernels"

entry mkSpMVdata (m: i64) (n: i64) (s: i64) : ([m]u32, []u32, []f32, [n*1]f32) =
  let (b, sinds, svals, densex1) = mkSparseMats m 1i64 n s
  in  (b, sinds, svals, flatten densex1)

-- ==
-- entry: spMVflatS spMVOuter spMVMidpt
-- "SpMV (sx,m,q)=(1024, 524288, 262144)" script input { mkSpMVdata 524288i64 262144i64 1024i64 }
-- output @ data/rep524288-256.out
--
-- "SpMV (sx,m,q)=(1024, 262144, 524288)" script input { mkSpMVdata 262144i64 524288i64 1024i64 }
-- output @ data/rep262144-512.out
--
-- "SpMV (sx,m,q)=( 128,  65536, 262144)" script input { mkSpMVdata  65536i64 262144i64  128i64 }
-- output @ data/rep65536-2048.out
--
-- "SpMV (sx,m,q)=( 128,  32768, 524288)" script input { mkSpMVdata  32768i64 524288i64  128i64 }
-- output @ data/rep32768-4096.out

entry spMVflatH [m][flen][p] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (vct: [p]f32) : [m]f32 =
  let spmat = zip sp_inds sp_vals
  in  spMatVecMulFlatH (B, spmat) vct

entry spMVflatS [m][flen][p] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (vct: [p]f32) : [m]f32 =
  let spmat = zip sp_inds sp_vals
  in  spMatVecMulFlatS (B, spmat) vct

entry spMVOuter [m][flen][p] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (vct: [p]f32) : [m]f32 =
  let spmat = zip sp_inds sp_vals
  in  spMatVecMulOuter (B, spmat) vct

entry spMVMidpt [m][flen][p] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (vct: [p]f32) : [m]f32 =
  let spmat = zip sp_inds sp_vals
  in  spMatVecMulMidpt (B, spmat) vct
