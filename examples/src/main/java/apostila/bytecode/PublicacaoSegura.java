package apostila.bytecode;

/** Publicação segura: flag volatile, campo final e duas formas de inicialização preguiçosa. */
public class PublicacaoSegura {
    private static volatile PublicacaoSegura instancia; // volatile: o DCL abaixo depende disso

    private final int limite;              // final: visível após o construtor
    private volatile boolean ativo = true; // volatile: flag lida por outras threads

    private PublicacaoSegura(int limite) {
        this.limite = limite;
    }

    /** Double-checked locking com campo volatile. */
    static PublicacaoSegura obter() {
        PublicacaoSegura local = instancia; // 1a leitura, sem lock
        if (local == null) {
            synchronized (PublicacaoSegura.class) {
                local = instancia;          // 2a leitura, com lock
                if (local == null) {
                    local = new PublicacaoSegura(10);
                    instancia = local;      // escrita volatile publica o objeto
                }
            }
        }
        return local;
    }

    /** Alternativa: idiom do holder; a JVM inicializa Portador uma vez, no primeiro uso. */
    private static class Portador {
        static final PublicacaoSegura INSTANCIA = new PublicacaoSegura(20);
    }

    static PublicacaoSegura obterPorPortador() {
        return Portador.INSTANCIA;
    }

    void parar() {
        ativo = false; // escrita volatile
    }

    boolean estaAtivo() {
        return ativo && limite > 0; // leitura volatile, depois o campo final
    }
}
