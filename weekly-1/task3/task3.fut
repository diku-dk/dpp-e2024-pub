import "lib/github.com/diku-dk/sorts/radix_sort"
-- ==
-- entry: segscan_test
-- input {
--          [1i32, 2i32, 3i32, 4i32, 1i32, 2i32, 3i32, 4i32]
--          [true, false, false, false, true, false, false, false]
--       }
-- output {[1i32, 3i32, 6i32, 10i32, 1i32, 3i32, 6i32, 10i32]}
-- input {
--          [1i32, 2i32, 3i32, 4i32, 1i32, 2i32, 3i32, 4i32]
--          [true, true, false, true, false, true, false, true]
--       }
-- output {[1i32, 2i32, 5i32, 4i32, 5i32, 2i32, 5i32, 4i32]}
-- compiled random input { [100000]i32 [100000]bool}
-- compiled random input { [1000000]i32 [1000000]bool}
-- compiled random input { [10000000]i32 [10000000]bool}
-- compiled random input { [100000000]i32 [100000000]bool}

-- ==
-- entry: scan_test
-- compiled random input { [100000]i32}
-- compiled random input { [1000000]i32 }
-- compiled random input { [10000000]i32}
-- compiled random input { [100000000]i32}

-- ==
-- entry: segreduce_test
-- input {
--          [1i32, 2i32, 3i32, 4i32, 1i32, 2i32, 3i32, 4i32]
--          [true, false, false, false, true, false, false, false]
--       }
-- output {[10i32, 10i32]}
-- input {
--          [1i32, 2i32, 3i32, 4i32, 1i32, 2i32, 3i32, 4i32]
--          [true, true, false, true, false, true, false, true]
--       }
-- output {[1i32, 5i32, 5i32, 5i32, 4i32]}
-- compiled random input { [100000]i32 [100000]bool}
-- compiled random input { [1000000]i32 [1000000]bool}
-- compiled random input { [10000000]i32 [10000000]bool}
-- compiled random input { [100000000]i32 [100000000]bool}

-- ==
-- entry: reduce_test
-- compiled random input { [100000]i32}
-- compiled random input { [1000000]i32 }
-- compiled random input { [10000000]i32}
-- compiled random input { [100000000]i32}

-- ==
-- entry: reduce_by_index_test
-- input {
--          [1i32,1i32,1i32]
--          [0i64,1i64,2i64]
--          [10i32, 12i32, 14i32]
--       }
-- output {[11i32, 13i32, 15i32]}
-- input {
--          [0i32,0i32,0i32]
--          [0i64,1i64,3i64]
--          [10i32, 12i32, 14i32]
--       }
-- output {[10i32, 12i32, 0i32]}
-- input {
--          [0i32,0i32,1i32,0i32]
--          [0i64,1i64,1i64,1i64,3i64, 3i64]
--          [10i32, 12i32, 1i32, 2i32, 2i32, 2i32]
--       }
-- output {[10i32, 15i32, 1i32, 4i32]}
-- compiled random input { [100000]i32 [100000]i64 [100000]i32}
-- compiled random input { [1000000]i32 [1000000]i64 [1000000]i32}
-- compiled random input { [10000000]i32 [10000000]i64 [10000000]i32}
-- compiled random input { [100000000]i32 [100000000]i64 [100000000]i32}

-- ==
-- entry: in_built_reduce_by_index_test
-- compiled random input { [100000]i32 [100000]i64 [100000]i32}
-- compiled random input { [1000000]i32 [1000000]i64 [1000000]i32}
-- compiled random input { [10000000]i32 [10000000]i64 [10000000]i32}
-- compiled random input { [100000000]i32 [100000000]i64 [100000000]i32}

def segscan [n] 't (op: t -> t -> t) (ne: t)
    (arr: [n](t, bool)): [n]t =
    let (vals, flags) = unzip arr
    let pairs = scan (\ (v1,f1) (v2,f2) ->
                       let f = f1 || f2
                       let v = if f2 then v2 else op v1 v2
                       in (v,f) ) (ne, false) (zip vals flags)
    let (res, _) = unzip pairs
    in res

def segreduce [n] 't (op: t -> t -> t) (ne: t)
    (arr: [n](t, bool)): []t =
    let (_, flags) = unzip arr
    let values = segscan op ne arr
    let newFlags = rotate (1) flags
    let filtered = zip newFlags (iota n)
                    |> filter (.0)
                    |> map (.1)
    in map (\i -> values[i]) filtered

def reduce_by_index_radix 'a [m] [n] 
    (dest : *[m]a) 
    (f : a -> a -> a)
    (ne : a)
    (is : [n]i64)
    (as : [n]a)
    : *[m]a =
    let zipped = zip is as
    let sorted = radix_sort_int_by_key (\t -> t.0) 32 i64.get_bit zipped
    let flags = map (\i -> if (i-1 >= 0 && sorted[i-1].0 != sorted[i].0 || i-1 < 0) then true else false) (indices sorted)
    let (is', as') = unzip sorted
    let final_indexes = segreduce (\_ y -> y) 0 ((zip is' flags) :> [n](i64, bool))
    let reduced = segreduce f ne ((zip as' flags) :> [n](a, bool))
    let final_length = length final_indexes
    let final_result = map2 (\i v -> if i < m && i >= 0 then f dest[i] v else v) (final_indexes :> [final_length]i64) (reduced :> [final_length]a)
    in scatter dest (final_indexes :> [final_length]i64) (final_result :> [final_length]a)

entry scan_test [n] (vals: [n]i32) : [n]i32 =
    scan (+) 0 vals

entry reduce_test [n] (vals: [n]i32) : i32 =
    reduce (+) 0 vals

entry segscan_test [n] (vals: [n]i32) (flags: [n]bool): [n]i32 =
    segscan (+) 0 (zip vals flags)

entry segreduce_test [n] (vals: [n]i32) (flags: [n]bool): []i32 =
    segreduce (+) 0 (zip vals flags)

entry reduce_by_index_test [n] [m] (dest: *[m]i32) (is: [n]i64) (as: [n]i32): *[m]i32 =
    reduce_by_index_radix dest (+) 0 is as

entry in_built_reduce_by_index_test [n] [m] (dest: *[m]i32) (is: [n]i64) (as: [n]i32): *[m]i32 =
    reduce_by_index dest (+) 0 is as
