import java.nio.file.*;
import java.security.*;
import java.util.*;

public class MerkleTreeFromCSV {

    public static void main(String[] args) throws Exception {
        // รายชื่อไฟล์ CSV ทั้งหมด
        String[] files = {
            "tree-level1.csv","tree-level2.csv","tree-level3.csv",
            "tree-level4.csv","tree-level5.csv","tree-level6.csv",
            "tree-level7.csv","tree-level8.csv","tree-level9.csv",
            "tree-level10.csv","tree-level11.csv","tree-level12.csv",
            "tree-level13.csv","tree-level14.csv"
        };

        List<String> leafHashes = new ArrayList<>();

        for (String file : files) {
            List<String> lines = Files.readAllLines(Paths.get(file));
            for (String line : lines) {
                leafHashes.add(sha256(line));
            }
        }

        String rootHash = buildMerkleTree(leafHashes);
        System.out.println("Merkle Root Hash: " + rootHash);
    }

    public static String sha256(String data) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(data.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    public static String buildMerkleTree(List<String> hashes) throws Exception {
        if (hashes.size() == 1) return hashes.get(0);

        List<String> parentHashes = new ArrayList<>();
        for (int i = 0; i < hashes.size(); i += 2) {
            String left = hashes.get(i);
            String right = (i + 1 < hashes.size()) ? hashes.get(i + 1) : left;
            parentHashes.add(sha256(left + right));
        }
        return buildMerkleTree(parentHashes);
    }
}


