import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class CourseManagementSystem extends JFrame {
    private JTextField BankNameField, BankCityField, LocationField, PhoneNumberField;
    private JTextArea courseListArea;
    private JButton addButton, printButton;
    private ArrayList<CourseInfo> courses;

    public CourseManagementSystem() {
        setTitle("银行网点信息管理系统");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 400);
        setLocationRelativeTo(null);

        courses = new ArrayList<>();

        // 创建输入框
        BankNameField = new JTextField(20);
        BankCityField = new JTextField(20);
        LocationField = new JTextField(20);
        PhoneNumberField = new JTextField(20);

        // 创建输出区域
        courseListArea = new JTextArea(10, 40);
        courseListArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(courseListArea);

        // 创建添加和打印按钮
        addButton = new JButton("添加网点");
        addButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                addCourse();
            }
        });

        printButton = new JButton("打印网点列表");
        printButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                printCourseList();
            }
        });

        // 设置布局
        JPanel inputPanel = new JPanel(new GridLayout(4, 2, 10, 10));
        inputPanel.add(new JLabel("网点名称:"));
        inputPanel.add(BankNameField);
        inputPanel.add(new JLabel("网点所在城市（包括省份）:"));
        inputPanel.add(BankCityField);
        inputPanel.add(new JLabel("详细地址:"));
        inputPanel.add(LocationField);
        inputPanel.add(new JLabel("电话:"));
        inputPanel.add(PhoneNumberField);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 10));
        buttonPanel.add(addButton);
        buttonPanel.add(printButton);

        JPanel mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.add(inputPanel, BorderLayout.NORTH);
        mainPanel.add(scrollPane, BorderLayout.CENTER);
        mainPanel.add(buttonPanel, BorderLayout.SOUTH);

        getContentPane().add(mainPanel);

        // 添加回车事件监听器
        KeyListener enterListener = new KeyListener() {
            @Override
            public void keyTyped(KeyEvent e) {
            }

            @Override
            public void keyPressed(KeyEvent e) {
                if (e.getKeyCode() == KeyEvent.VK_ENTER) {
                    addCourse();
                } else if (e.getKeyCode() == KeyEvent.VK_P && e.isControlDown()) {
                    printCourseList();
                }
            }

            @Override
            public void keyReleased(KeyEvent e) {
            }
        };
        BankNameField.addKeyListener(enterListener);
        BankCityField.addKeyListener(enterListener);
        LocationField.addKeyListener(enterListener);
        PhoneNumberField.addKeyListener(enterListener);

        // 从数据库加载课程信息
        loadCoursesFromDatabase();
    }

    private void addCourse() {
        String BankName = BankNameField.getText();
        String BankCity = BankCityField.getText();
        String Location = LocationField.getText();
        int PhoneNumber = Integer.parseInt(PhoneNumberField.getText());

        CourseInfo course = new CourseInfo(BankName, BankCity, Location, PhoneNumber);
        courses.add(course);
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mysql", "roots", "12345");
            PreparedStatement stmt = conn
                    .prepareStatement("INSERT INTO courses (name, city, location, phone number) VALUES (?, ?, ?, ?)");
            stmt.setString(1, BankName);
            stmt.setString(2, BankCity);
            stmt.setString(3, Location);
            stmt.setInt(4, PhoneNumber);
            stmt.executeUpdate();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        updateCourseList();
        resetFields();
    }

    private void loadCoursesFromDatabase() {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mysql", "roots", "12345");
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM courses");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String BankName = rs.getString("name");
                String BankCity = rs.getString("city");
                String Location = rs.getString("location");
                int PhoneNumber = rs.getInt("phonenumber");
                CourseInfo course = new CourseInfo(BankName, BankCity, Location, PhoneNumber);
                courses.add(course);
            }
            updateCourseList();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void updateCourseList() {
        courseListArea.setText("");
        for (CourseInfo course : courses) {
            courseListArea.append(course.toString() + "\n");
        }
    }

    private void printCourseList() {
        StringBuilder sb = new StringBuilder();
        for (CourseInfo course : courses) {
            sb.append(course.toString()).append("\n");
        }
        JOptionPane.showMessageDialog(this, sb.toString(), "网点信息列表", JOptionPane.INFORMATION_MESSAGE);
    }

    private void resetFields() {
        BankNameField.setText("");
        BankCityField.setText("");
        LocationField.setText("");
        PhoneNumberField.setText("");
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            CourseManagementSystem cms = new CourseManagementSystem();
            cms.setVisible(true);
        });
    }
}

class CourseInfo {
    private String BankName;
    private String BankCity;
    private String Location;
    private int PhoneNumber;

    public CourseInfo(String BankName, String BankCity, String Location, int PhoneNumber) {
        this.BankName = BankName;
        this.BankCity = BankCity;
        this.Location = Location;
        this.PhoneNumber = PhoneNumber;
    }

    @Override
    public String toString() {
        return "网点名称: " + BankName + ", 网点所在城市（包括省份）: " + BankCity + ", 详细地址: " + Location + ", 电话: " + PhoneNumber;
    }
}