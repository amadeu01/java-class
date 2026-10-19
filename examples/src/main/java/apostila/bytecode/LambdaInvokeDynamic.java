package apostila.bytecode;

import java.util.function.Function;

/** Lambda: o javac gera invokedynamic (LambdaMetafactory), sem classe anônima. */
public class LambdaInvokeDynamic {
    static Function<Integer, Integer> dobro() {
        // invokedynamic apply -> bootstrap LambdaMetafactory.metafactory
        return x -> x * 2;
    }

    public static void main(String[] args) {
        System.out.println(dobro().apply(21));
    }
}
