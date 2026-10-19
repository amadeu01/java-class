package apostila.bytecode;

/** switch sobre String: hashCode() + lookupswitch, depois equals(). */
public class SwitchStrings {
    static int codigo(String cor) {
        switch (cor) {
            case "vermelho": return 1;
            case "verde": return 2;
            default: return 0;
        }
    }

    public static void main(String[] args) {
        System.out.println(codigo("verde"));
    }
}
