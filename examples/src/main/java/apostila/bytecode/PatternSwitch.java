package apostila.bytecode;

/** switch com pattern matching: invokedynamic typeSwitch (SwitchBootstraps). */
public class PatternSwitch {
    static String descrever(Object o) {
        return switch (o) {
            case Integer i when i > 10 -> "inteiro grande";
            case Integer i -> "inteiro";
            case String s -> "texto de " + s.length();
            default -> "outro";
        };
    }

    public static void main(String[] args) {
        System.out.println(descrever(42));
    }
}
