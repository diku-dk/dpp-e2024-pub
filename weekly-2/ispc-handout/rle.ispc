export uniform int rle_ispc(uniform int output[], uniform int input[], uniform int n) {
    uniform int prev_value = input[0];
    uniform int m = 1;
    uniform int inserted_vals = 0;
    foreach (i = 1 ... n) {
        int j = input[i];
        if (all(j == prev_value)) {
            if (i > n-programCount)
            {
                int remaining = n - i;
                m += extract(remaining, 0);
            } else {
                m += programCount;
            }
        } else {
            if (programIndex == 0) {
                for(int q = 0; q < programCount; q++)
                {   
                    int next = input[i+q];
                    if (next == prev_value) {
                        m += 1;
                    } else {
                        output[inserted_vals] = m;
                        output[inserted_vals + 1] = prev_value;
                        prev_value = extract(next, 0);
                        inserted_vals += 2;
                        m = 1;
                    }
                }
            }
        }
    }
    if (programIndex == 0) {
        output[inserted_vals] = m;
        output[inserted_vals + 1] = prev_value;
        inserted_vals += 2;
    }
    return inserted_vals;
}
