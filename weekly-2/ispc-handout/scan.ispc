export void scan_ispc(uniform float output[], uniform float input[], uniform int n) {
    float acc = 0;
    
    foreach(i = 0 ... n)
    {
        float f = input[i];
        float res = exclusive_scan_add(f);
        float inc = f + res + acc;
        acc = extract(inc, programCount-1);
        output[i] = inc;
    }
}
