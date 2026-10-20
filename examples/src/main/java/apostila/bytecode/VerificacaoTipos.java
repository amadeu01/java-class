package apostila.bytecode;

/** Um int e uma referência em slots diferentes: iload/istore contra aload/astore. */
public class VerificacaoTipos {
    static int combinar() {
        int quantidade = 3;
        String rotulo = "itens";
        return quantidade + rotulo.length();
    }

    public static void main(String[] args) {
        System.out.println(combinar());
    }
}
