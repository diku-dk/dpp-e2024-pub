def imap xs f = map f xs
def imap2 xs ys f = map2 f xs ys

def mkFlagArray 't [m] 
            (aoa_shp: [m]u32) (zero: t)     -- aoa_shp=[0,3,1,0,4,2,0]
            (aoa_val: [m]t)  
          : ([m]u32, []t) =                 -- aoa_val=[1,1,1,1,1,1,1]
  let shp_rot = map (\i->if i==0 then 0     -- shp_rot=[0,0,3,1,0,4,2]
                         else aoa_shp[i-1]
                    ) (iota m)
  let shp_scn = scan (+) 0 shp_rot          -- shp_scn=[0,0,3,4,4,8,10]
  let aoa_len = if m == 0 then 0i64         --aoa_len = 10
                else i64.u32 <|
                     shp_scn[m-1]+aoa_shp[m-1]
  let shp_ind = map2 (\shp ind ->           -- shp_ind= 
                       if shp==0 then -1i64 --  [-1,0,3,-1,4,8,-1]
                       else i64.u32 ind     -- scatter
                     ) aoa_shp shp_scn      --   [0,0,0,0,0,0,0,0,0,0]
  let r = scatter (replicate aoa_len zero)  --   [-1,0,3,-1,4,8,-1]
             shp_ind aoa_val                --   [1,1,1,1,1,1,1]
  in (shp_scn, r)                           -- r = [1,0,0,1,1,0,0,0,1,0]

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

def binSearch [n] (as: [n]u32) (x: u32) : u32 = #[unsafe]
  let n = assert (n > 0) n in
  if x >= last as then u32.i64 (n-1)
  else
    let (l, h, _) =
      loop (l, h, found) = (0u32, u32.i64 n - 1, false)
      while l <= h && !found do
        let m  = (l + h) / 2
        let ma = #[unsafe] as[i64.u32 m]
        in
        if ma < x then (m+1, h, false)
        else if x < ma then (l, m-1, false)
        else (m, m, true)
    --
    in if l != h then h
       else let ma = #[unsafe] as[i64.u32 l] in
            loop m = h while m < u32.i64 n - 1 && #[unsafe]as[i64.u32 m + 1] == ma do m+1

-- Testing binary Search
-- == entry: testBinSearch
-- input  { [0u32, 2u32, 3u32, 7u32, 12u32, 19u32, 28u32, 31u32, 33u32, 37u32, 37u32, 37u32, 37u32, 37u32, 42u32, 42u32] 
--          [0u32, 1u32, 4u32, 3u32, 28u32, 29u32, 30u32, 31u32, 32u32, 33u32, 34u32, 35u32, 36u32, 37u32, 38u32, 42u32, 44u32]
--        }
-- output { [0u32, 0u32, 2u32, 2u32, 6u32, 6u32, 6u32, 7u32, 7u32, 8u32, 8u32, 8u32, 8u32, 13u32, 13u32, 15u32, 15u32] }
    
entry testBinSearch [n][m] (as: [n]u32) (xs: [m]u32) : [m]u32 =
  map (binSearch as) xs

