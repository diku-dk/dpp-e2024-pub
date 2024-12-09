-- # Tree operations.
--
-- We import a library so we don't have to write a segmented scan
-- ourselves. Remember to run `futhark pkg sync` to download it.
import "lib/github.com/diku-dk/segmented/segmented"

-- A traversal is an array of these steps.
type step = #u | #d i32

-- ## Input handling.
--
-- You do not have to modify this. The function 'input.steps' takes as
-- argument a string with steps as discussed in the assignment text,
-- and gives you back an array of type '[]step'.
--
-- Example:
--
-- ```
-- > input.steps "d0 d2 d3 u u d5 u"
-- [#d 0, #d 2, #d 3, #u, #u, #d 5, #u]
-- ```

-- ==
-- entry: depths_test
-- input {
--          "d0 d2 d3 u u d5 u"
--       }
-- output {
--  [0i64, 1i64, 2i64, 1i64]
--  [0i32, 2i32, 3i32, 5i32]
-- }
-- input {
--          "d0 d2 u d3 u d0 d4 u d0 u u d0 d5"
--       }
-- output {
--  [0i64, 1i64, 1i64, 1i64, 2i64, 2i64, 1i64, 2i64]
--  [0i32, 2i32, 3i32, 0i32, 4i32, 0i32, 0i32, 5i32]
-- }

-- ==
-- entry: parents_test
-- input {
--          [0i64, 1i64, 2i64, 1i64]
--       }
-- output {
--  [0i64, 0i64, 1i64, 0i64]
-- }
-- input {
--          [0i64, 1i64, 1i64, 1i64, 2i64, 2i64, 1i64, 2i64]
--       }
-- output {
--  [0i64, 0i64, 0i64, 0i64, 3i64, 3i64, 0i64, 6i64]
-- }

-- ==
-- entry: subtree_sizes_test
-- input {
--          "d0 d2 u d3 u d0 d4 u d0 u u d0 d5"
--       }
-- output {
--  [14i32, 2i32, 3i32, 4i32, 4i32, 0i32, 5i32, 5i32]
-- }

type char = u8
type string [n] = [n]char

module input: {
  -- | Parse a string into an array of commands.
  val steps [n] : string[n] -> []step
} = {
  def is_space (x: char) = x == ' ' || x == '\n'
  def isnt_space x = !(is_space x)

  def f &&& g = \x -> (f x, g x)

  def dtoi (c: char): i32 = i32.u8 c - '0'

  def is_digit (c: char) = c >= '0' && c <= '9'

  def atoi [n] (s: string[n]): i32 =
    let (sign,s) = if n > 0 && s[0] == '-' then (-1,drop 1 s) else (1,s)
    in sign * (loop (acc,i) = (0,0) while i < length s do
                 if is_digit s[i]
                 then (acc * 10 + dtoi s[i], i+1)
                 else (acc, n)).0

  def to_step (s: []char) : step =
    match s[0]
    case 'u' -> #u
    case _ -> #d (atoi (drop 1 s))

  def steps [n] (s: string[n]) =
    segmented_scan (+) 0 (map is_space s) (map (isnt_space >-> i64.bool) s)
    |> (id &&& rotate 1)
    |> uncurry zip
    |> zip (indices s)
    |> filter (\(i,(x,y)) -> (i == n-1 && x > 0) || x > y)
    |> map (\(i,(x,_)) -> to_step s[i-x+1:i+1])
}

def map_step_to_tuple (steps: []step) : [](i64,i32) =
  map (\s -> 
    match s
    case #u -> (-1, 0)
    case #d z -> (1, z)
  ) steps

def add_tuple(x: (i64,i32)) (y: (i64,i32)) : (i64,i32) =
  (x.0 + y.0, y.1)
-- ## Task 2.1

def depths (steps: []step) : [](i64,i32) =
  let steps_to_tuple = map_step_to_tuple steps
  let unfiltered_result = scan (add_tuple) (0, 0) steps_to_tuple
  let filtered_result = filter (\x -> x.0.0 >= 0) (zip steps_to_tuple unfiltered_result)
  let (_, result) = unzip filtered_result
  in map (\x -> (x.0-1, x.1)) result

entry depths_test (chars : string []) : ([]i64, []i32) =
  unzip (depths (input.steps chars))
  
-- ## Task 2.2
def parents (D: []i64) : []i64 =
  map (\i -> 
    loop j = i while j > 0 && D[i] <= D[j] do
      (j-1)
  ) (indices D)

entry parents_test (D: []i64) : []i64 =
  parents D

-- ## Task 2.3
def subtree_sizes [n] (steps: [n]step) : []i32 =
  let all_depths = depths steps
  let l = length all_depths
  let (_, values) = unzip all_depths
  in
  map2 (
    \d i ->
      if i == 0 then
        reduce (+) 0 values
      else
        let (_, accumulated_res) = loop (j, acc) = (i, 0) while j < l && d.0 < all_depths[j].0 || i == j do
          (j + 1, acc + all_depths[j].1)
        in accumulated_res
    ) all_depths (indices all_depths)
  
entry subtree_sizes_test (chars : string []) :  []i32 =
  subtree_sizes (input.steps chars)

entry main (chars : string []) : ([]i32) =
  subtree_sizes (input.steps chars)
