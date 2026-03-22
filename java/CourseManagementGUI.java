import javax.swing.*;
import java.awt.*;
import java.io.IOException;

public class CourseManagementGUI extends JFrame {
    private MainApplication MainApplication;
    private CourseSearchApp courseSearchApp;
    private CourseManagementSystem courseManagementSystem;
    private CoursedeleteApp coursedeleteApp;
    private CourseManager courseManager;

    public CourseManagementGUI(String username) {
        // 设置窗口标题和大小
        setTitle("尊贵的" + username + "的银行网点管理系统");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        // 创建面板并添加按钮
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.CENTER, 25, 20));
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JButton queryButton = new JButton("查询");
        queryButton.addActionListener(e -> openCourseSearchApp());

        JButton addButton = new JButton("添加网点信息");
        addButton.addActionListener(e -> openCourseManagementSystem());

        JButton listButton = new JButton("查看网点列表");
        listButton.addActionListener(e -> showCourseList());

        JButton deleteButton = new JButton("删除网点列表");
        deleteButton.addActionListener(e -> CoursedeleteApp());

        JButton modifyButton = new JButton("修改网点信息");
        modifyButton.addActionListener(e -> openCourseModifyApp());
        panel.add(queryButton);
        panel.add(addButton);
        panel.add(listButton);
        panel.add(deleteButton);
        panel.add(modifyButton);
        // 添加面板到窗口
        add(panel, BorderLayout.CENTER);
    }

    private void openCourseModifyApp() {
        if (courseManager == null) {
            courseManager = new CourseManager();
        }
        courseManager.setVisible(true);
    }

    private void openCourseSearchApp() {
        if (courseSearchApp == null) {
            courseSearchApp = new CourseSearchApp();
        }
        courseSearchApp.setVisible(true);
    }

    private void openCourseManagementSystem() {
        if (courseManagementSystem == null) {
            courseManagementSystem = new CourseManagementSystem();
        }
        courseManagementSystem.setVisible(true);
    }

    private void showCourseList() {
        // 在此处实现显示课程列表的功能
        if (MainApplication == null) {
            MainApplication = new MainApplication();
        }
        MainApplication.setVisible(true);
    }

    private void CoursedeleteApp() {
        // 在此处实现显示课程列表的功能
        if (coursedeleteApp == null) {
            coursedeleteApp = new CoursedeleteApp();
        }
        coursedeleteApp.setVisible(true);
    }
}