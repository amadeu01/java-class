package apostila.bytecode;

/** Buffer limitado com métodos synchronized: wait() dentro de um while e notifyAll(). */
public class EsperaEmLaco {
    private final int[] itens = new int[2];
    private int quantidade;
    private int inicio;

    synchronized void colocar(int valor) throws InterruptedException {
        while (quantidade == itens.length) {
            wait(); // libera o monitor de this enquanto espera
        }
        itens[(inicio + quantidade) % itens.length] = valor;
        quantidade++;
        notifyAll();
    }

    synchronized int retirar() throws InterruptedException {
        while (quantidade == 0) {
            wait(); // ao voltar, a condição é testada de novo
        }
        int valor = itens[inicio];
        inicio = (inicio + 1) % itens.length;
        quantidade--;
        notifyAll();
        return valor;
    }

    public static void main(String[] args) throws InterruptedException {
        EsperaEmLaco buffer = new EsperaEmLaco();
        Thread produtor = new Thread(() -> {
            try {
                for (int i = 1; i <= 5; i++) {
                    buffer.colocar(i);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        produtor.start();
        for (int i = 0; i < 5; i++) {
            System.out.println(buffer.retirar());
        }
        produtor.join();
    }
}
