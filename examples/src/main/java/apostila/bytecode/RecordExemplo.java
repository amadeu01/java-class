package apostila.bytecode;

/** record: classe final com accessors e equals/hashCode/toString via ObjectMethods. */
public class RecordExemplo {
    record Ponto(int x, int y) {}

    public static void main(String[] args) {
        System.out.println(new Ponto(1, 2));
    }
}
