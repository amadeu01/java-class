package apostila.bytecode;

/** Para javap -v: constant pool, descritores e BootstrapMethods num exemplo pequeno. */
public class PoolConstantes {
    static final int LIMITE = 1000; // constante: o javac copia o valor (sipush), sem getstatic
    static String rotulo(int n) {
        return n > LIMITE ? "grande: " + n : "pequeno";
    }
}
