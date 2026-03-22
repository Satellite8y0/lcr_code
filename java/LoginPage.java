import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.sql.*;

public class LoginPage extends JFrame {
    private JPanel panel;
    private JLabel usernameLabel, passwordLabel, usernameInputLabel, passwordInputLabel;
    private JTextField usernameField;
    private JPasswordField passwordField;
    private JButton loginButton, cancelButton;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/mysql";
    private static final String DB_USER = "roots";
    private static final String DB_PASSWORD = "12345";

    public LoginPage() {
        // 设置窗口标题和大小
        setTitle("登录");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        // 创建面板
        panel = new JPanel(new GridLayout(3, 2, 10, 10));

        // 创建用户名标签和文本框
        usernameLabel = new JLabel("用户名:");
        panel.add(usernameLabel);

        usernameField = new JTextField(20);
        panel.add(usernameField);

        // 创建用户名输入提示标签,并将其放在用户名文本框的后面
        usernameInputLabel = new JLabel();
        panel.add(usernameInputLabel);

        // 创建密码标签和密码框
        passwordLabel = new JLabel("密码:");
        panel.add(passwordLabel);

        passwordField = new JPasswordField(20);
        passwordField.setEchoChar('*');
        panel.add(passwordField);

        // 创建密码输入提示标签,并将其放在密码文本框的后面
        passwordInputLabel = new JLabel();
        panel.add(passwordInputLabel);

        // 创建登录和取消按钮
        loginButton = new JButton("登录");
        loginButton.addActionListener(e -> performLogin());
        panel.add(loginButton);

        cancelButton = new JButton("取消");
        cancelButton.addActionListener(e -> dispose());
        panel.add(cancelButton);

        // 添加面板到窗口
        add(panel, BorderLayout.CENTER);
    }

    private void performLogin() {
        String username = usernameField.getText();
        String password = new String(passwordField.getPassword());

        if (verifyLogin(username, password)) {
            // 登录成功,跳转到管理页面
            JOptionPane.showMessageDialog(this, "登录成功!");
            // 跳转到管理页面的代码
            dispose(); // 关闭当前登录页面
            CourseManagementGUI sd = new CourseManagementGUI(username);
            sd.setVisible(true);
            // 执行 CourseManagementSystemTest.java 文件
            try {
                // 使用 Java 的 Runtime 类执行 Java 命令
                Runtime.getRuntime().exec("java CourseManagementGUI");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            JOptionPane.showMessageDialog(this, "用户名或密码错误,请重试.");
        }
    }

    private boolean verifyLogin(String username, String password) {
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                PreparedStatement stmt = conn
                        .prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?")) {
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            return rs.next(); // 如果查询结果有数据,说明用户名密码正确
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String[] args) {
        // 显示登录页面
        LoginPage loginPage = new LoginPage();
        loginPage.setVisible(true);
    }
}