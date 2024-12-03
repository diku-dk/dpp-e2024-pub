import "mk-datasets"
import "kernels"
import "../../util"

----------------------------------------
--- dense-dense matrix multipication ---
----------------------------------------

entry mkDenseData (m: i64) (m': i64) (n: i64) (s: i64) : ([m][n]f32, [n][m']f32) =
  mkDenseMats m m' n s

entry mkSpMMdata (m: i64) (m': i64) (n: i64) (s: i64) : ([m]u32, []u32, []f32, [n][m']f32) =
  mkSparseMats m m' n s

-- ==
-- entry: denseMMM
-- "Dense (sx,m,m',q)=(128,2048,2048, 32768)" script input { mkDenseData 2048i64 2048i64  32768i64 128i64 }
-- output @ data/rep2048x2048-256.out
--
-- "Dense (sx,m,m',q)=(128,2048,2048,131072)" script input { mkDenseData 2048i64 2048i64 131072i64 128i64 }
-- output @ data/rep2048x2048-1024.out
--
-- "Dense (sx,m,m',q)=( 64,2048,2048, 65536)" script input { mkDenseData 2048i64 2048i64  65536i64  64i64 }
-- output @ data/rep2048x2048-1024.out
--
-- "Dense (sx,m,m',q)=( 64,2048,2048,131072)" script input { mkDenseData 2048i64 2048i64 131072i64  64i64 }
-- output @ data/rep2048x2048-2048.out

entry denseMMM [m][n][q] (xss: [m][q]f32) (yss: [q][n]f32) : [m][n]f32 =
  let dotprod as bs = map2 (*) as bs |> reduce (+) 0
  in  imap xss (\xs -> imap (transpose yss) (dotprod xs))
  



-- ==
-- entry: spMMFlatS spMMOuter spMMMidpt
-- "SpMM (sx,m,m',q)=(128, 2048, 2048, 32768)" script input { mkSpMMdata 2048i64 2048i64 32768i64 128i64 }
-- output @ data/rep2048x2048-256.out
--
-- "SpMM (sx,m,m',q)=(128, 2048, 2048, 131072)" script input { mkSpMMdata 2048i64 2048i64 131072i64 128i64 }
-- output @ data/rep2048x2048-1024.out
--
-- "SpMM (sx,m,m',q)=( 64, 2048, 2048, 65536)" script input { mkSpMMdata 2048i64 2048i64 65536i64  64i64 }
-- output @ data/rep2048x2048-1024.out
--
-- "SpMM (sx,m,m',q)=( 64, 2048, 2048, 131072)" script input { mkSpMMdata 2048i64 2048i64 131072i64  64i64 }
-- output @ data/rep2048x2048-2048.out


entry spMMFlatS [m][flen][p][n] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (dense: [p][n]f32) : [m][n]f32 =
  let denseT  = copy (transpose dense)
  let denseTM = if opaque(true) then denseT else denseT with [0,0] = 0.0f32
  let spmat   = zip sp_inds sp_vals
  in  denseTM |> map (spMatVecMulFlatS (B,spmat)) |> transpose

entry spMMOuter [m][flen][p][n] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (dense: [p][n]f32) : [m][n]f32 =
  let denseT  = copy (transpose dense)
  let denseTM = if opaque(true) then denseT else denseT with [0,0] = 0.0f32
  let spmat   = zip sp_inds sp_vals
  in  denseTM |> map (spMatVecMulOuter (B,spmat)) |> transpose

entry spMMMidpt [m][flen][p][n] (B: [m]u32) (sp_inds: [flen]u32) (sp_vals: [flen]f32) (dense: [p][n]f32) : [m][n]f32 =
  let denseT  = copy (transpose dense)
  let denseTM = if opaque(true) then denseT else denseT with [0,0] = 0.0f32
  let spmat   = zip sp_inds sp_vals
  in  denseTM |> map (spMatVecMulMidpt (B,spmat)) |> transpose
