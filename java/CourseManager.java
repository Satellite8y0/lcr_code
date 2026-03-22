import java.sql.*;
import java.util.Scanner;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

import java.awt.*;
import java.awt.event.*;

public class CourseManager extends JFrame {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mysql";
    private static final String DB_USER = "roots";
    private static final String DB_PASS = "12345";

    private DefaultTableModel tableModel;
    private JTable courseTable;
    private JTextField nameField, cityField, locationField, Field;
    private JButton updateButton;
    private int selectedCourseId = -1;

    /**
     * 
     */
    public CourseManager() {
        setTitle("Bank Manager");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);

        // 创建课程信息表格
        tableModel = new DefaultTableModel();
        tableModel.addColumn("ID");
        tableModel.addColumn("银行名称");
        tableModel.addColumn("所在城市");
        tableModel.addColumn("详细地址");
        tableModel.addColumn("电话");
        courseTable = new JTable(tableModel);
        courseTable.setFillsViewportHeight(true);
        // courseTable = new JTable(getCourseData(), getColumnNames());
        loadCourseData();
        courseTable.getSelectionModel().addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting()) {
                int selectedRow = courseTable.getSelectedRow();
                if (selectedRow != -1) {
                    selectedCourseId = (int) courseTable.getValueAt(selectedRow, 0);
                    nameField.setText((String) courseTable.getValueAt(selectedRow, 1));
                    cityField.setText((String) courseTable.getValueAt(selectedRow, 2));
                    locationField.setText((String) courseTable.getValueAt(selectedRow, 3));
                    Field.setText(String.valueOf((int) courseTable.getValueAt(selectedRow, 4)));
                }
            }
        });
        JScrollPane scrollPane = new JScrollPane(courseTable);
        add(scrollPane, BorderLayout.CENTER);

        // 创建修改课程信息的面板
        JPanel inputPanel = new JPanel(new GridLayout(5, 2, 10, 10));
        inputPanel.add(new JLabel("名称："));
        nameField = new JTextField();
        inputPanel.add(nameField);
        inputPanel.add(new JLabel("城市："));
        cityField = new JTextField();
        inputPanel.add(cityField);
        inputPanel.add(new JLabel("地址："));
        locationField = new JTextField();
        inputPanel.add(locationField);
        inputPanel.add(new JLabel("电话："));
        Field = new JTextField();
        inputPanel.add(Field);
        updateButton = new JButton("更新");
        updateButton.addActionListener(e -> updateCourse());
        inputPanel.add(updateButton);
        add(inputPanel, BorderLayout.SOUTH);
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
                String city = rs.getString("city");
                String location = rs.getString("location");
                int phonenumber = rs.getInt("phonenumber");
                tableModel.addRow(new Object[] { id, name, city, location, phonenumber });
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

    private void updateCourse() {
        if (selectedCourseId == -1) {
            JOptionPane.showMessageDialog(this, "请选择一个网点更新.");
            return;
        }

        String name = nameField.getText().trim();
        String city = cityField.getText().trim();
        String location = locationField.getText().trim();
        int phonenumber;
        try {
            phonenumber= Integer.parseInt(Field.getText().trim());
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "无效的电话");
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                PreparedStatement stmt = conn.prepareStatement(
                        "UPDATE courses SET name = ?, city = ?, location = ?,  = ? WHERE id = ?")) {
            stmt.setString(1, name);
            stmt.setString(2, city);
            stmt.setString(3, location);
            stmt.setInt(4,phonenumber );
            stmt.setInt(5, selectedCourseId);
            int rowsUpdated = stmt.executeUpdate();
            if (rowsUpdated > 0) {
                JOptionPane.showMessageDialog(this, "网点更新成功");
                updateCourseTable();
            } else {
                JOptionPane.showMessageDialog(this, "网点更新失败");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "更新过程中出现错误");
        }
    }

    private void updateCourseTable() {
        loadCourseData();
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            CourseManager courseManager = new CourseManager();
            courseManager.setVisible(true);
        });
    }
}