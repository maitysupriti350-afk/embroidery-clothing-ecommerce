import java.sql.*;
public class TempDBTest {
  public static void main(String[] args) throws Exception {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection c = DriverManager.getConnection("jdbc:mysql://localhost:3306/clothingstore?useSSL=false&allowPublicKeyRetrieval=true","root","admin123")) {
      System.out.println("connect-ok");
    }
  }
}
