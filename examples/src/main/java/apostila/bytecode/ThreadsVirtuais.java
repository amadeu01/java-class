package apostila.bytecode;

import java.util.concurrent.Executors;

/** Virtual threads: no bytecode é só uma chamada de método; o trabalho está no runtime. */
public class ThreadsVirtuais {
    public static void main(String[] args) {
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            for (int i = 0; i < 10_000; i++) {
                int tarefa = i;
                executor.submit(() -> {
                    Thread.sleep(10); // bloqueia: a virtual thread desmonta do carrier
                    return tarefa;
                });
            }
        } // close() espera todas as tarefas terminarem
    }
}
