import java.io.*;

public class MerkleTreeLoop {
    public static void main(String[] args) throws Exception {
        for (int i = 1; i <= 14; i++) {
            String filename = "../csv/tree-level" + i + ".csv";
            BufferedReader br = new BufferedReader(new FileReader(filename));
            System.out.println("Reading: " + filename);
            // อ่านข้อมูล → สร้าง hash → ต่อยอดไปยังระดับถัดไป
            br.close();
        }
    }
}

