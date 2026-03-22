public class System1 {
    public static Object out;
    private LoginPage loginPage;

    public System1() {
        if (loginPage == null) {
            loginPage = new LoginPage();
        }
        loginPage.setVisible(true);
    }
}