package apostila.experimentos;

import java.time.Duration;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.IntStream;

/**
 * O exemplo do JEP 444: 10.000 tarefas, cada uma dormindo 1 s, com uma
 * virtual thread por tarefa e com um pool fixo de 200 threads de plataforma.
 * A versão com virtual threads roda duas vezes na mesma JVM (aquecimento).
 */
public class ThreadsVirtuaisVsPool {
    static final int TAREFAS = 10_000;

    public static void main(String[] args) {
        for (int rodada = 1; rodada <= 2; rodada++) {
            mede("virtual, rodada " + rodada, Executors.newVirtualThreadPerTaskExecutor());
        }
        mede("pool fixo de 200", Executors.newFixedThreadPool(200));
    }

    static void mede(String nome, ExecutorService executor) {
        long inicio = System.nanoTime();
        try (executor) {
            IntStream.range(0, TAREFAS).forEach(i -> executor.submit(() -> {
                Thread.sleep(Duration.ofSeconds(1));
                return i;
            }));
        } // close() espera todas as tarefas terminarem
        double segundos = (System.nanoTime() - inicio) / 1e9;
        System.out.printf("%-20s %d tarefas em %.2f s (%.0f tarefas/s)%n",
                nome + ":", TAREFAS, segundos, TAREFAS / segundos);
    }
}
