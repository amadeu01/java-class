package apostila.bytecode;

import java.lang.reflect.Field;

/** Injeção em campo: por reflexão (campo private) e por código gerado (package-private). */
public class InjecaoSemReflexao {
    static class Repositorio {}

    static class Servico {
        private Repositorio privado;  // fora da classe e do seu nest, só por reflexão
        Repositorio pacote;           // package-private: putfield direto
    }

    /** O que um container que descobre beans em runtime precisa fazer. */
    static void porReflexao(Servico s, Repositorio r) throws ReflectiveOperationException {
        Field f = Servico.class.getDeclaredField("privado");
        f.setAccessible(true);
        f.set(s, r);
    }

    /** O que uma classe gerada em build time, no mesmo pacote, pode fazer. */
    static void direto(Servico s, Repositorio r) {
        s.pacote = r;
    }
}
