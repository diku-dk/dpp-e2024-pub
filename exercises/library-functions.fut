-- Library functions:
-- ==
-- entry: rotate
-- input {
--    1i64
--    [1i32, 2i32, 3i32, 4i32]
-- }
-- output {
--    [4i32, 1i32, 2i32, 3i32]
-- }
-- input {
--    -1i64
--    [1i32, 2i32, 3i32, 4i32]
-- }
-- output {
--    [2i32, 3i32, 4i32, 1i32]
-- }
--

-- Matrix multiplication.
-- ==
-- entry: matmul
-- input { [[1, 2]] [[3], [4]] }
-- output { [[11]] }
-- input { [[1, 2], [3, 4]] [[5, 6], [7, 8]] }
-- output { [[19, 22], [43, 50]] }
--

entry matmul [n][m][p] (x: [n][m]i32) (y: [m][p]i32): [n][p]i32 =
  map (\xr -> map (\yc -> reduce (+) 0 (map2 (*) xr yc))
                  (transpose y))
      x

entry rotate [n] (r: i64) (xs: [n]i32) : [n]i32 =
  let shift = r * (-1i64) in
  if r < 0
     then ((xs[shift:n] ++ xs[0:shift]) :> [n]i32)
     else ((xs[n - r:n] ++ xs[0:n - r]) :> [n]i32)