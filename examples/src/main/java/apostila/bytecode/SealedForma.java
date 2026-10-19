package apostila.bytecode;

/** sealed + records + switch exaustivo: sem default, o javac gera um que lança MatchException. */
public class SealedForma {
    sealed interface Forma permits Circulo, Quadrado {}
    record Circulo(double raio) implements Forma {}
    record Quadrado(double lado) implements Forma {}

    static double area(Forma f) {
        return switch (f) {
            case Circulo c -> Math.PI * c.raio() * c.raio();
            case Quadrado q -> q.lado() * q.lado();
        };
    }

    public static void main(String[] args) {
        System.out.println(area(new Quadrado(3)));
    }
}
