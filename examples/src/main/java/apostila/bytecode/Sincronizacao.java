package apostila.bytecode;

/** Bloco synchronized: monitorenter e monitorexit (com saída em exceção). */
public class Sincronizacao {
    private int contador;

    void incrementar() {
        synchronized (this) {
            contador++;
        }
    }

    public static void main(String[] args) {
        Sincronizacao s = new Sincronizacao();
        s.incrementar();
        System.out.println(s.contador);
    }
}
