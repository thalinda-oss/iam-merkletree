#!/usr/bin/env python3
"""
merkle_compute.py
คำนวณ Merkle Root จากไฟล์ CSV
ใช้คู่กับ verify_all.sh
"""
import argparse, glob, hashlib, os, sys

def sha256(b: bytes) -> bytes:
    return hashlib.sha256(b).digest()

def merkle_root_from_leaves(leaves):
    if not leaves:
        return b''
    nodes = [sha256(l) for l in leaves]
    while len(nodes) > 1:
        if len(nodes) % 2 == 1:
            nodes.append(nodes[-1])  # duplicate last
        nodes = [sha256(nodes[i] + nodes[i+1]) for i in range(0, len(nodes), 2)]
    return nodes[0]

def read_leaves_from_file(path, mode):
    if mode == "file":
        return [open(path, "rb").read()]
    else:
        with open(path, "rb") as f:
            return [line.strip() for line in f if line.strip()]

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--pattern", required=True)
    p.add_argument("--mode", choices=("line", "file"), default="line")
    p.add_argument("--out", default=None)
    args = p.parse_args()

    files = sorted(glob.glob(args.pattern))
    if not files:
        print("❌ No files found for pattern:", args.pattern, file=sys.stderr)
        sys.exit(1)

    results = []
    for fp in files:
        leaves = read_leaves_from_file(fp, args.mode)
        root = merkle_root_from_leaves(leaves)
        root_hex = root.hex()
        print(f"{os.path.basename(fp)}\troot={root_hex}\tleaves={len(leaves)}")
        results.append(f"{os.path.basename(fp)}\t{root_hex}\t{len(leaves)}\n")

    if args.out:
        with open(args.out, "w") as f:
            f.writelines(results)
        print("✅ Wrote results to", args.out)

if __name__ == "__main__":
    main()
