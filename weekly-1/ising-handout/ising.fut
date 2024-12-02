-- We represent a spin as a single byte.  In principle, we need only
-- two values (-1 or 1), but Futhark represents booleans a a full byte
-- entirely, so using an i8 instead takes no more space, and makes the
-- arithmetic simpler.
type spin = i8

import "lib/github.com/diku-dk/cpprandom/random"

-- Pick an RNG engine and define random distributions for specific types.
module rng_engine = minstd_rand
module rand_f32 = uniform_real_distribution f32 rng_engine
module rand_i8 = uniform_int_distribution i8 rng_engine

-- We can create an few RNG state with 'rng_engine.rng_from_seed [x]',
-- where 'x' is some seed.  We can split one RNG state into many with
-- 'rng_engine.split_rng'.
--
-- For an RNG state 'r', we can generate random integers that are
-- either 0 or 1 by calling 'rand_i8.rand (0i8, 1i8) r'.
--
-- For an RNG state 'r', we can generate random floats in the range
-- (0,1) by calling 'rand_f32.rand (0f32, 1f32) r'.
--
-- Remember to consult
-- https://futhark-lang.org/pkgs/github.com/diku-dk/cpprandom/latest/

def rand = rand_f32.rand (0f32, 1f32)
def randi = rand_i8.rand (0i8, 1i8)

-- Create a new grid of a given size.  Also produce an identically
-- sized array of RNG states.
def random_grid (seed: i32) (h: i64) (w: i64)
              : ([h][w]rng_engine.rng, [h][w]spin) =
  let l = iota (h*w)

  let r_seed = rng_engine.rng_from_seed [seed]
  let rngs = rng_engine.split_rng (h*w) r_seed

  let init = map2 (\_ r -> 
                    let x = randi r
                    in
                    if x.1 == 0 
                      then (x.0, -1)
                    else (x.0, 1)
                    ) l rngs
  let (new_rngs, spins) = (map (\x -> x.0) init, map (\x -> x.1) init)       
  in (unflatten new_rngs, unflatten spins)
-- Compute $\Delta_e$ for each spin in the grid, using wraparound at
-- the edges.
def deltas [h][w] (spins: [h][w]spin): [h][w]i8 =
  let flattened_spins = spins |> flatten
  let left_spins = map (\a -> rotate (-1) a) spins |> flatten
  let right_spins = map (\a -> rotate 1 a) spins |> flatten
  let up_spins = rotate 1 spins |> flatten
  let down_spins = rotate (-1) spins |> flatten
  in map5 (\c u d l r -> 2*c*(u+d+l+r)) flattened_spins up_spins down_spins left_spins right_spins |> unflatten

-- The sum of all deltas of a grid.  The result is a measure of how
-- ordered the grid is.
def delta_sum [h][w] (spins: [w][h]spin): i32 =
  ???

-- Take one step in the Ising 2D simulation.
def step [h][w] (abs_temp: f32) (samplerate: f32)
                (rngs: [h][w]rng_engine.rng) (spins: [h][w]spin)
              : ([h][w]rng_engine.rng, [h][w]spin) =
  let flattened_spins = flatten spins
  let flattened_deltas = map (\d -> f32.i8 d) (flatten (deltas spins))
  
  let a_b_r = map (\r -> 
                    let (r2, a) = rand r
                    let (r3, b) = rand r2
                    in ((a,b),r3)
                  ) (flatten rngs)

  let new_rngs = map (\t -> t.1) a_b_r
  let new_spins = map3 (\s abr d -> if ((abr.0).0 < samplerate && (d < (-d) || (abr.0).1 < f32.exp((-d)/abs_temp)))
                                    then (-s) else s)
                                    flattened_spins a_b_r flattened_deltas |> unflatten 
  in (unflatten new_rngs, new_spins)

-- | Just for benchmarking.
def main (abs_temp: f32) (samplerate: f32)
         (h: i64) (w: i64) (n: i32): [h][w]spin =
  (loop (rngs, spins) = random_grid 1337 h w for _i < n do
     step abs_temp samplerate rngs spins).1

-- ==
-- entry: main
-- input { 0.5f32 0.1f32 10i64 10i64 2 } auto output
-- input { 0.5f32 0.1f32 10i64 10i64 1000 } auto output
-- input { 0.5f32 0.1f32 10i64 10i64 10000 } auto output
-- input { 0.5f32 0.1f32 10i64 10i64 100000 } auto output
-- input { 0.5f32 0.1f32 100i64 100i64 100000 } auto output
-- input { 1.0f32 0.1f32 10i64 10i64 1000 } auto output
-- input { 0.5f32 0.5f32 10i64 10i64 1000 } auto output
-- input { 0.5f32 0.7f32 10i64 10i64 1000 } auto output
-- input { 0.5f32 0.1f32 20i64 10i64 1000 } auto output
-- input { 0.5f32 0.1f32 20i64 20i64 1000 } auto output
-- input { 0.5f32 0.1f32 100i64 10i64 1000 } auto output
-- input { 0.5f32 0.1f32 10i64 100i64 1000 } auto output

-- The following definitions are for the visualisation and need not be modified.

type~ state = {cells: [][](rng_engine.rng, spin)}

entry tui_init seed h w : state =
  let (rngs, spins) = random_grid seed h w
  in {cells=map (uncurry zip) (zip rngs spins)}

entry tui_render (s: state) = map (map (.1)) s.cells

entry tui_step (abs_temp: f32) (samplerate: f32) (s: state) : state =
  let rngs = (map (map (.0)) s.cells)
  let spins = map (map (.1)) s.cells
  let (rngs', spins') = step abs_temp samplerate rngs spins
  in {cells=map (uncurry zip) (zip rngs' spins')}
