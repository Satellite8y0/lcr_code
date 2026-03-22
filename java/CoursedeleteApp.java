import java.awt.*;
import java.sql.*;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

public class CoursedeleteApp extends JFrame {
    private JTextField BankNameField, BankCityField, LocationField, PhoneNumberField;
    private JTable resultTable;
    private Connection conn;
    private PreparedStatement pstmt;

    public CoursedeleteApp() {
        // 初始化 UI 组件
        JPanel searchPanel = new JPanel(new GridLayout(2, 4, 10, 10));
        BankNameField = new JTextField();
        BankCityField = new JTextField();
        LocationField = new JTextField();
        PhoneNumberField = new JTextField();
        JButton searchByNameBtn = new JButton("搜索银行名称");
        JButton searchByCodeBtn = new JButton("搜索所在城市（包括省份）");
        JButton searchByInstructorBtn = new JButton("搜索详细地址");
        JButton searchByCreditBtn = new JButton("搜索网点电话");
        JButton deleteBtn = new JButton("删除课程");
        searchPanel.add(new JLabel("银行名称:"));
        searchPanel.add(BankNameField);
        searchPanel.add(searchByNameBtn);
        searchPanel.add(deleteBtn);
        searchPanel.add(new JLabel("所在城市（包括省份）:"));
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

        resultTable = new JTable(new DefaultTableModel(new Object[] { "银行名称", "所在城市（包括省份）", "详细地址", "电话" }, 0));
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
        searchByNameBtn.addActionListener(e -> performSearch("bank", BankNameField.getText()));
        searchByCodeBtn.addActionListener(e -> performSearch("city", BankCityField.getText()));
        searchByInstructorBtn.addActionListener(e -> performSearch("location", LocationField.getText()));
        searchByCreditBtn.addActionListener(e -> performSearch("phonenumber", PhoneNumberField.getText()));

        // 设置删除按钮的动作监听器
        deleteBtn.addActionListener(e -> deleteCourse());
    }

    private void performSearch(String columnName, String searchText) {
        String sql = "SELECT * FROM bank WHERE %s LIKE '%s'";
        sql = String.format(sql, columnName, "%" + searchText + "%");
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            DefaultTableModel model = (DefaultTableModel) resultTable.getModel();
            model.setRowCount(0); // 清空表格
            boolean hasResult = false;
            while (rs.next()) {
                hasResult = true;
                String BankName = rs.getString("name");
                String Bankcity = rs.getString("city");
                String Location = rs.getString("location");
                int PhoneNumber = rs.getInt("phonenumber");
                model.addRow(new Object[] { BankName, Bankcity, Location, PhoneNumber });
            }
            if (!hasResult) {
                model.addRow(new Object[] { "没有找到相关银行信息", "", "", 0 });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void deleteCourse() {
        int selectedRow = resultTable.getSelectedRow();
        if (selectedRow != -1) {
            String BankName = (String) resultTable.getValueAt(selectedRow, 0);
            String Bankcity = (String) resultTable.getValueAt(selectedRow, 1);
            try {
                String sql = "DELETE FROM courses WHERE name = ? AND code = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, BankName);
                pstmt.setString(2, Bankcity);
                int rowsDeleted = pstmt.executeUpdate();
                if (rowsDeleted > 0) {
                    JOptionPane.showMessageDialog(this, "网点已删除: " + BankName + " (" + Bankcity + ")");
                    ((DefaultTableModel) resultTable.getModel()).removeRow(selectedRow);
                } else {
                    JOptionPane.showMessageDialog(this, "删除网点失败: " + BankName + " (" + Bankcity + ")");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            JOptionPane.showMessageDialog(this, "请先选择要删除的网点");
        }
    }

    public static void main(String[] args) {
        new CoursedeleteApp();
    }
}