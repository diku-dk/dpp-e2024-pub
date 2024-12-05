---------------------------------------
--- utilities for creating datasets ---
---------------------------------------

-- compute (7*x^2 + 11*x + 13) % n
-- where x = i + 1
def rand (n: i64) (i: i64) : i64 =
  let x  = i+1
  let x2 = x * x
  in  (7*x2 + 11*x + 13) % n 

entry mkReplicate1 (m: i64) (v: i64) =
  replicate m (f32.i64 v)

entry mkReplicate2 (m: i64) (n: i64) (v: i64) =
  replicate m (replicate n (f32.i64 v))

def mkDenseMats (m: i64) (m': i64) (n: i64) (s: i64) : ([m][n]f32, [n][m']f32) =
  let row_chunks = assert (n % s == 0) (n/s)
  let f i =
      let inds = tabulate row_chunks (\ c -> rand s (i+c))
      in  tabulate n (\ j-> let c = j / s in
                            if j == c*s + inds[c]
                            then 1f32
                            else 0
                     )
  let sp_mat = tabulate m f
  let dn_mat = replicate n (replicate m' 1f32)
  in  (sp_mat, dn_mat)

def mkSparseMats (m: i64) (m': i64) (n: i64) (s: i64) : ([m]u32, []u32, []f32, [n][m']f32) =
  let row_chunks = assert (n % s == 0) (n/s)
  let f i =
      tabulate row_chunks
        (\ c -> (u32.i64 (c*s + rand s (i+c)), 1f32))
  let (sp_mat_inds, sp_mat_vals) = tabulate m f |> flatten |> unzip
  -- let shape = replicate m row_chunks
  let B = tabulate m (\ i -> u32.i64 (i*row_chunks))
  let dn_mat = replicate n (replicate m' 1f32)
  in  (B, sp_mat_inds, sp_mat_vals, dn_mat)

