# Define the directory path
DATA_DIR="data"

default: run-spmm

run-spmm:
	futhark bench --backend=cuda spmat-mat-mul.fut

run-spmv:
	futhark bench --backend=cuda spmat-vec-mul.fut -r 100

datasets:
	mkdir -p data 
	futhark cuda mk-datasets.fut
	echo "524288i64 256i64" | ./mk-datasets -e mkReplicate1 -b > data/rep524288-256.out
	echo "262144i64 512i64" | ./mk-datasets -e mkReplicate1 -b > data/rep262144-512.out
	echo "65536i64 2048i64" | ./mk-datasets -e mkReplicate1 -b > data/rep65536-2048.out
	echo "32768i64 4096i64" | ./mk-datasets -e mkReplicate1 -b > data/rep32768-4096.out
	echo "2048i64 2048i64  256i64" | ./mk-datasets -e mkReplicate2 -b > data/rep2048x2048-256.out
	echo "2048i64 2048i64 1024i64" | ./mk-datasets -e mkReplicate2 -b > data/rep2048x2048-1024.out
	echo "2048i64 2048i64 2048i64" | ./mk-datasets -e mkReplicate2 -b > data/rep2048x2048-2048.out

clean:
	rm -rf *.c spmat-vec-mul spmat-mat-mul mk-datasets
	rm -rf *.actual *.expected
