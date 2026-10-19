package apostila.bytecode;

/** Autoboxing: int vira Integer via Integer.valueOf; == compara referências. */
public class Autoboxing {
    static boolean iguais(Integer a, Integer b) {
        return a == b; // armadilha: compara referências (if_acmpne), não valores
    }

    public static void main(String[] args) {
        Integer a = 127, b = 127; // Integer.valueOf usa cache de -128 a 127
        Integer c = 128, d = 128; // fora do cache: objetos distintos
        System.out.println(iguais(a, b)); // true
        System.out.println(iguais(c, d)); // false
    }
}
