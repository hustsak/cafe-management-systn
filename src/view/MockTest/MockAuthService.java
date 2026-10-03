package view.MockTest;

import Interface.IAuthService;
import Interface.IUser;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.prefs.Preferences;

public class MockAuthService implements IAuthService {

    private static final Map<String, IUser> usersMap = new ConcurrentHashMap<>();
    private static IUser currentUser = null;
    private static String rememberedUsername = "";

    private static final Preferences prefs = Preferences.userNodeForPackage(MockAuthService.class);
    private static final String PREF_REMEMBERED_USER = "remembered_username";
    private static final String PREF_USER_PREFIX = "user_pass_";
    private static final String PREF_USER_ROLE_PREFIX = "user_role_";
    private static final String PREF_USER_LIST = "user_list";

    static {
        // Default users
        MockUser admin = new MockUser("admin", "123456", "Manager");
        MockUser staff = new MockUser("staff", "123456", "Staff");
        usersMap.put(admin.getUsername(), admin);
        usersMap.put(staff.getUsername(), staff);

        // Load persisted registered users
        loadSavedUsers();

        // Load remembered username
        rememberedUsername = prefs.get(PREF_REMEMBERED_USER, "");
        if (rememberedUsername.isEmpty() && !usersMap.isEmpty()) {
            rememberedUsername = "admin";
        }
    }

    public MockAuthService() {}

    private static void loadSavedUsers() {
        try {
            String userListStr = prefs.get(PREF_USER_LIST, "");
            if (!userListStr.isEmpty()) {
                String[] usernames = userListStr.split(",");
                for (String un : usernames) {
                    un = un.trim();
                    if (!un.isEmpty()) {
                        String pass = prefs.get(PREF_USER_PREFIX + un, "");
                        String role = prefs.get(PREF_USER_ROLE_PREFIX + un, "Manager");
                        if (!pass.isEmpty()) {
                            usersMap.put(un, new MockUser(un, pass, role));
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void saveUserToPrefs(IUser user) {
        try {
            String un = user.getUsername();
            String pass = user.getPassWord();
            String role = user.getRole();
            prefs.put(PREF_USER_PREFIX + un, pass != null ? pass : "");
            prefs.put(PREF_USER_ROLE_PREFIX + un, role != null ? role : "Manager");

            String userListStr = prefs.get(PREF_USER_LIST, "");
            if (!userListStr.contains(un)) {
                if (!userListStr.isEmpty()) userListStr += ",";
                userListStr += un;
                prefs.put(PREF_USER_LIST, userListStr);
            }
            prefs.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setUser(MockUser user) {
        if (user != null && user.getUsername() != null) {
            usersMap.put(user.getUsername(), user);
            setRememberedUsername(user.getUsername());
            saveUserToPrefs(user);
        }
    }

    public void addUser(IUser user) {
        if (user != null && user.getUsername() != null) {
            usersMap.put(user.getUsername(), user);
            setRememberedUsername(user.getUsername());
            saveUserToPrefs(user);
        }
    }

    public static boolean login(String username, String password) {
        if (username == null || password == null) {
            return false;
        }
        username = username.trim();
        IUser user = usersMap.get(username);
        if (user != null && user.getPassWord() != null && user.getPassWord().equals(password)) {
            currentUser = user;
            setRememberedUsername(username);
            return true;
        }
        return false;
    }

    @Override
    public void logout() {
        currentUser = null;
    }

    public IUser getCurrentUser() {
        return currentUser;
    }

    public String getRememberedUsername() {
        return rememberedUsername;
    }

    public static void setRememberedUsername(String username) {
        if (username != null) {
            rememberedUsername = username.trim();
            prefs.put(PREF_REMEMBERED_USER, rememberedUsername);
            try {
                prefs.flush();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}