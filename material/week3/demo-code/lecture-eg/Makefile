# Define the directory path
DATA_DIR="data"

run: lecture-eg.fut
	futhark bench --backend=cuda lecture-eg.fut

datasets:
	mkdir -p data 
	futhark dataset --u32-bounds=1:2000000 -g [1000]u32 -b > data/ref1000sgms.in
	futhark dataset --u32-bounds=1:200000 -g [10000]u32 -b > data/ref10000sgms.in
	futhark dataset --u32-bounds=1:20000 -g [100000]u32 -b > data/ref100000sgms.in
	futhark dataset --u32-bounds=1:2000 -g [1000000]u32 -b > data/ref1000000sgms.in

clean:
	rm -rf *.c lecture-eg
	rm -rf *.actual *.expected
