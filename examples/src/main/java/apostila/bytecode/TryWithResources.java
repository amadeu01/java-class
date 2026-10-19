package apostila.bytecode;

/** try-with-resources: close() automático e addSuppressed no tratamento de erro. */
public class TryWithResources {
    static class Recurso implements AutoCloseable {
        @Override
        public void close() {
            System.out.println("fechado");
        }
    }

    static void usar() {
        try (Recurso r = new Recurso()) {
            System.out.println("usando " + r.getClass().getSimpleName());
        }
    }

    public static void main(String[] args) {
        usar();
    }
}
