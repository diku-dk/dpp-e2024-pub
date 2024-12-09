export uniform int pack_ispc(uniform int output[], uniform int input[], uniform int n) {
  uniform int m = 1;
  uniform int prev_iteration_value = input[0];
  output[0] = input[0];
  foreach (i = 1 ... n) {
    int j = input[i];
    int prev_value;
    if (programIndex == 0) {
        prev_value = prev_iteration_value;
    } else {
        prev_value = rotate(j, -1);
    }
    int keep = j != prev_value;
    int offset = exclusive_scan_add(keep);
    if(!keep) {
        offset = programCount-1;
    }
    output[m + offset] = j;
    m += reduce_add(keep);
    prev_iteration_value = extract(j, programCount-1);
  }
  return m;
}
