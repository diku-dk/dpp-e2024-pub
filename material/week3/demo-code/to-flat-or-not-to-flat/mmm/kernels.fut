import "../../util"

def imapIntra as f =
  #[incremental_flattening(only_intra)] map f as

-----------------------------------------------
--- sparse matrix vector multipication:     ---
--- sparse matrix is of dense shape `m x p` ---
--- dense vector is of length `p`           ---
-----------------------------------------------

def spMatVecMulFlatH [m][flen][p] (B: [m]u32, spmat: [flen](u32,f32)) (vec: [p]f32) : [m]f32 =
  let II1 = iota flen |> map u32.i64 |> map (binSearch B) 
  in  spmat
     |> map (\ (ind,elm) -> elm * #[unsafe]vec[i64.u32 ind]) 
     |> hist (+) 0f32 m (map i64.u32 II1)

def spMatVecMulFlatS [m][flen][p] (B: [m]u32, spmat: [flen](u32,f32)) (vec: [p]f32) : [m]f32 =
  let flags = scatter (replicate flen false) (map i64.u32 B) (replicate m true)
  let prods = imap spmat (\ (ind,elm) -> elm * #[unsafe]vec[i64.u32 ind])
  let scn_mat = sgmScan (+) 0f32 flags prods
  in  tabulate m
        (\i -> if i == m-1
               then last scn_mat
               else let ind = i64.u32 (#[unsafe]B[i+1]-1)
                    in #[unsafe] scn_mat[ind]
        )

def spMatVecMulOuter [m][flen][p] (B: [m]u32, spmat: [flen](u32,f32)) (vec: [p]f32) : [m]f32 =
  let f i = #[unsafe]
    let beg = i64.u32 B[i]
    let end = if i == m-1 then flen else i64.u32 B[i+1] in
    loop sum = 0 for i < end - beg do
      let (j,v) = spmat[i + beg]
      in  sum + v*vec[i64.u32 j]
  in tabulate m f

def spMatVecMulMidpt [m][flen][p] (B: [m]u32, spmat: [flen](u32,f32)) (vec: [p]f32) : [m]f32 =
  let block = 64i64 -- should use a better heursitic based on B
  let f i = #[unsafe]
    let beg = i64.u32 B[i]
    let end = if i == m-1 then flen else i64.u32 B[i+1]
    let sums=
      imap (iota block)
        (\ tid ->
            loop sum = 0f32 for i < (end - beg + block - 1) / block do 
              let ind = beg + i*block + tid
              let (j,v) = if ind < end then spmat[ind] else (u32.i64 p, 0.0f32)
              in  sum + (if j < u32.i64 p then v*vec[i64.u32 j] else 0.0f32)
        )
    in reduce (+) 0f32 sums
  in #[incremental_flattening(only_intra)] map f (iota m)
  
-----------------------------------------------
--- sparse-dense matrix multipication:      ---
--- sparse matrix is of dense shape `m x p` ---
--- dense  matrix is of shape `p x n`       ---
-----------------------------------------------

