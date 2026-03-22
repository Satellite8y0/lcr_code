import javax.swing.*;
import javax.swing.table.DefaultTableModel;

import java.awt.*;
import java.sql.*;

public class MainApplication extends JFrame {
    public MainApplication() {
        setTitle("课程信息");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);

        // 创建 CourseInfoDetailsGUI 面板并添加到窗口
        CourseInfoDetailsGUI courseInfoPanel = new CourseInfoDetailsGUI();
        getContentPane().add(courseInfoPanel, BorderLayout.CENTER);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            MainApplication mainApp = new MainApplication();
            mainApp.setVisible(true);
        });
    }
}

class CourseInfoDetailsGUI extends JPanel {
    private JTable courseTable;
    private DefaultTableModel tableModel;

    public CourseInfoDetailsGUI() {
        setLayout(new BorderLayout());

        // 创建表格模型
        tableModel = new DefaultTableModel();
        tableModel.addColumn("ID");
        tableModel.addColumn("银行名称");
        tableModel.addColumn("所在城市");
        tableModel.addColumn("详细地址");
        tableModel.addColumn("电话");

        // 创建表格并添加到面板
        courseTable = new JTable(tableModel);
        courseTable.setFillsViewportHeight(true);
        JScrollPane scrollPane = new JScrollPane(courseTable);
        add(scrollPane, BorderLayout.CENTER);

        // 从数据库中读取课程信息并添加到表格
        loadCourseData();
    }

    private void loadCourseData() {
        try {
            // 连接到数据库
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mysql", "roots",
                    "12345");

            // 执行 SQL 查询
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM bank");

            // 将查询结果添加到表格模型
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String code = rs.getString("city");
                String instructor = rs.getString("location");
                int credit = rs.getInt("phonenumber");
                tableModel.addRow(new Object[] { id, name, code, instructor, credit });
            }

            // 关闭数据库连接
            rs.close();
            stmt.close();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "读取数据库失败: " + e.getMessage(), "错误", JOptionPane.ERROR_MESSAGE);
        }
    }
}