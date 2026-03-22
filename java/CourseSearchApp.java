import java.awt.*;
import java.sql.*;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.tools.JavaFileManager.Location;

public class CourseSearchApp extends JFrame {
    private JTextField BankNameField, BankCityField, LocationField, PhoneNumberField;
    private JTable resultTable;
    private Connection conn;
    private PreparedStatement pstmt;

    public CourseSearchApp() {
        // 初始化 UI 组件
        JPanel searchPanel = new JPanel(new GridLayout(2, 4, 10, 10));
        BankNameField = new JTextField();
        BankCityField = new JTextField();
        LocationField = new JTextField();
        PhoneNumberField = new JTextField();
        JButton searchByNameBtn = new JButton("搜索银行名称");
        JButton searchByCodeBtn = new JButton("搜索所在地址");
        JButton searchByInstructorBtn = new JButton("搜索详细地址");
        JButton searchByCreditBtn = new JButton("搜索电话");
        searchPanel.add(new JLabel("银行名称:"));
        searchPanel.add(BankNameField);
        searchPanel.add(searchByNameBtn);
        searchPanel.add(new JLabel());
        searchPanel.add(new JLabel("所在地址:"));
        searchPanel.add(BankCityField);
        searchPanel.add(searchByCodeBtn);
        searchPanel.add(new JLabel());
        searchPanel.add(new JLabel("详细地址:"));
        searchPanel.add(LocationField);
        searchPanel.add(searchByInstructorBtn);
        searchPanel.add(new JLabel());
        searchPanel.add(new JLabel("电话:"));
        searchPanel.add(PhoneNumberField);
        searchPanel.add(searchByCreditBtn);
        searchPanel.add(new JLabel());

        resultTable = new JTable(new DefaultTableModel(new Object[] { "银行名称", "所在地址", "详细地址", "电话" }, 0));
        JScrollPane scrollPane = new JScrollPane(resultTable);

        getContentPane().add(searchPanel, "North");
        getContentPane().add(scrollPane, "Center");

        setTitle("银行网点搜索应用");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        pack();
        setVisible(true);

        // 连接数据库
        try {
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mysql", "roots",
                    "12345");
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 设置搜索按钮的动作监听器
        searchByNameBtn.addActionListener(e -> performSearch("name", BankNameField.getText()));
        searchByCodeBtn.addActionListener(e -> performSearch("code", BankCityField.getText()));
        searchByInstructorBtn.addActionListener(e -> performSearch("instructor", LocationField.getText()));
        searchByCreditBtn.addActionListener(e -> performSearch("credit", PhoneNumberField.getText()));
    }

    private void performSearch(String columnName, String searchText) {
        String sql = "SELECT * FROM courses WHERE %s LIKE '%s'";
        sql = String.format(sql, columnName, "%" + searchText + "%");
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            DefaultTableModel model = (DefaultTableModel) resultTable.getModel();
            model.setRowCount(0); // 清空表格
            boolean hasResult = false;
            while (rs.next()) {
                hasResult = true;
                String courseName = rs.getString("name");
                String courseCode = rs.getString("code");
                String instructor = rs.getString("instructor");
                int credits = rs.getInt("credit");
                model.addRow(new Object[] { courseName, courseCode, instructor, credits });
            }
            if (!hasResult) {
                model.addRow(new Object[] { "没有找到相关课程信息", "", "", 0 });
            }
            if (columnName.equals("name")) {
                BankNameField.setText("");
            } else if (columnName.equals("code")) {
                BankCityField.setText("");
            } else if (columnName.equals("instructor")) {
                LocationField.setText("");
            } else if (columnName.equals("credit")) {
                PhoneNumberField.setText("");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        new CourseSearchApp();
    }
}