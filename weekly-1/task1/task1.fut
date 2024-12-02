-- ==
-- entry: process_test
-- compiled random input { [100]i32 [100]i32}
-- compiled random input { [1000]i32 [1000]i32}
-- compiled random input { [10000]i32 [10000]i32}
-- compiled random input { [100000]i32 [100000]i32}
-- compiled random input { [1000000]i32 [1000000]i32}
-- compiled random input { [10000000]i32 [10000000]i32}

-- ==
-- entry: process_idx_test
-- compiled random input { [100]i32 [100]i32}
-- compiled random input { [1000]i32 [1000]i32}
-- compiled random input { [10000]i32 [10000]i32}
-- compiled random input { [100000]i32 [100000]i32}
-- compiled random input { [1000000]i32 [1000000]i32}
-- compiled random input { [10000000]i32 [10000000]i32}

def process [n] ( s1: [n]i32 ) (s2: [n]i32) : i32 =
    let diff = map2 (\a b -> i32.abs (a - b)) s1 s2
    in reduce (+) 0 diff

def process_idx [n] ( s1: [n]i32 ) (s2: [n]i32) : (i32, i64) =
    let diff = zip (map2 (\a b -> i32.abs (a - b)) s1 s2) (iota n)
    in reduce ((\(v1, i1) (v2, i2) -> if v1 > v2 then (v1, i1) else (v2, i2))) (0, 0i64) diff

entry process_test [n] (s1: [n]i32) (s2: [n]i32): i32 =
    process s1 s2

entry process_idx_test [n] (s1: [n]i32) (s2: [n]i32): (i32, i64) =
    process_idx s1 s2