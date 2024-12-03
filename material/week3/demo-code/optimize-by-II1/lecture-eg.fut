-----------------------------------------------------------------
--- This refers to flattening the example presented in class: ---
---   map (\i -> let ip1 = i+1
---              let iot = (iota i)
---              let ip1r= (replicate i ip1)
---              in  map2 (+) ip1r iot
---       ) arr
--- We assume for simplicity that the input array holds
---   strictly-positive integers (i.e., > 0)
-----------------------------------------------------------------

def sgmScan 't [n] (op: t->t->t) (ne: t) 
                   (flg : [n]bool) (arr : [n]t) : [n]t =
  let flgs_vals =
    zip flg arr |>
    scan ( \ (f1, x1) (f2, x2) -> 
            let f = f1 || f2
            in  if f2 then (f, x2)
                else (f, op x1 x2) 
         ) (false,ne)
  let (_, vals) = unzip flgs_vals
  in vals

def classicKer [n] (arr: [n]u32) : []u32 = #[unsafe]    -- [1, 2, 3, 4]
  -- make offsets
  let B = iota n                                        -- [0, 1, 3, 6]
       |> map (\i -> if i==0 then 0u32 else arr[i-1])
       |> scan (+) 0
  let size = (last B) + (last arr) |> i64.u32           -- 6 + 4 = 10
  -- make flag array (unsafe when null segments exist)
  let flag = replicate n true                           -- [1, 2, 0, 3, 0, 0, 4, 0, 0, 0]
          |> scatter (replicate size false) (map i64.u32 B)
  --
  -- trivial map distribution:
  let ip1s = map (\i -> i+1) arr                        -- [2, 3, 4, 5]
  --
  -- rule iota nested inside map:
  let iotsp1 = sgmScan (+) 0 flag (replicate size 1u32) -- [1, 1, 2, 1, 2, 3, 1, 2, 3, 4]
  --
  -- rule replicate nested inside map:
  let vals   = scatter (replicate size 0u32)            -- [2, 3, 0, 4, 0, 0, 5, 0, 0, 0]
                       (map i64.u32 B) ip1s
  let ip1rs  = sgmScan (+) 0 flag vals                  -- [2, 3, 3, 4, 4, 4, 5, 5, 5, 5]
  --
  -- rule map nested inside map:
  let result = map (\x -> x-1) iotsp1                   -- [2, 3, 4, 4, 5, 6, 5, 6, 7, 8]
            |> map2 (+) ip1rs
  in  result
  
def explII1Ker [n] (arr: [n]u32) : []u32 = #[unsafe]
  -- make offsets
  let B = iota n
       |> map (\i -> if i==0 then 0u32 else arr[i-1])
       |> scan (+) 0
  let size = (last B) + (last arr) |> i64.u32
  --
  -- make II1:
  let tmp = map (\off -> if off==0u32 then 0u32 else 1u32) B
         |> scatter (replicate size 0u32) (map i64.u32 B)
  let II1 = scan (+) 0 tmp
  --
  -- flatten kernel
  let f (sgm_ind : u32) (flat_ind: u32) = #[unsafe]
        let sgm_ind = i64.u32 sgm_ind
        let ip1 = arr[sgm_ind] + 1
        let iot_elm = flat_ind - B[sgm_ind]
        let res_elm = ip1 + iot_elm
        in  res_elm
  in iota size |> map u32.i64 |> map2 f II1

def binSearch [n] (as: [n]u32) (x: u32) : u32 = #[unsafe]
  if x >= last as then u32.i64 (n-1)
  else
    let (_, h, _) =
      loop (l, h, found) = (0u32, u32.i64 n - 1, false)
      while l <= h && !found do
        let m  = (l + h) / 2
        let ma = #[unsafe] as[i64.u32 m]
        in
        if ma < x then (m+1, h, false)
        else if x < ma then (l, m-1, false)
        else (m, m, true)
    --
    in h

def implII1Ker [n] (arr: [n]u32) : []u32 = #[unsafe]
  -- make offsets
  let B = iota n
       |> map (\i -> if i==0 then 0u32 else arr[i-1])
       |> scan (+) 0
  let size = (last B) + (last arr) |> i64.u32
  --
  -- make II1:  
  let II1 = iota size |> map u32.i64 |> map (binSearch B) 
  --
  -- flatten kernel
  let f (sgm_ind : u32) (flat_ind: u32) = #[unsafe]
        let sgm_ind = i64.u32 sgm_ind
        let ip1 = arr[sgm_ind] + 1
        let iot_elm = flat_ind - B[sgm_ind]
        let res_elm = ip1 + iot_elm
        in  res_elm
  in iota size |> map u32.i64 |> map2 f II1


-- Primes: Flat-Parallel Version
-- == entry: II1Impl II1Expl classic
-- input  { [1u32, 2u32, 3u32, 4u32] }
-- output { [2u32, 3u32, 4u32, 4u32, 5u32, 6u32, 5u32, 6u32, 7u32, 8u32] }
--
-- compiled input @ data/ref1000sgms.in
-- compiled input @ data/ref10000sgms.in
-- compiled input @ data/ref100000sgms.in
-- compiled input @ data/ref1000000sgms.in

entry classic [n] (array : [n]u32) : []u32 =
  classicKer array

entry II1Expl [n] (array : [n]u32) : []u32 =
  explII1Ker array

entry II1Impl [n] (array : [n]u32) : []u32 =
  implII1Ker array
