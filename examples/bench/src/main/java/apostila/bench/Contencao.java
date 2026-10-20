package apostila.bench;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.LongAdder;

import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;

/**
 * Três formas de incrementar um contador compartilhado por todas as
 * threads do benchmark. O número de threads vem de fora (-t 1, -t 8),
 * passado por scripts/bench.sh.
 */
@State(Scope.Benchmark)
@BenchmarkMode(Mode.Throughput)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
public class Contencao {

    // Contador protegido pelo monitor de um objeto privado.
    private final Object trava = new Object();
    private long contadorSincronizado;

    private final AtomicLong contadorAtomico = new AtomicLong();
    private final LongAdder contadorSomador = new LongAdder();

    @Benchmark
    public long synchronizedIncrement() {
        synchronized (trava) {
            return ++contadorSincronizado;
        }
    }

    @Benchmark
    public long atomicLongIncrement() {
        return contadorAtomico.incrementAndGet();
    }

    @Benchmark
    public void longAdderIncrement() {
        contadorSomador.increment();
    }
}
