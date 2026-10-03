package model;

import Interface.IAuthService;
import Interface.IUser;
import view.MockTest.MockUser;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.prefs.Preferences;

public class AuthService implements IAuthService {

    private static final Map<String, IUser> usersMap = new ConcurrentHashMap<>();
    private static IUser currentUser = null;
    private static String rememberedUsername = "";

    private static final Preferences prefs = Preferences.userNodeForPackage(AuthService.class);
    private static final String PREF_REMEMBERED_USER = "remembered_username";

    static {
        MockUser admin = new MockUser("admin", "123456", "Manager");
        MockUser staff = new MockUser("staff", "123456", "Staff");
        usersMap.put(admin.getUsername(), admin);
        usersMap.put(staff.getUsername(), staff);
        rememberedUsername = prefs.get(PREF_REMEMBERED_USER, "admin");
    }

    public AuthService(){}

    public void setUser(User user){
        if (user != null && user.getUsername() != null) {
            usersMap.put(user.getUsername(), user);
            setRememberedUsername(user.getUsername());
        }
    }

    public static boolean login(String username, String password) {
        if (username == null || password == null) return false;
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
        }
    }
}