package apostila.bytecode;

/** Concatenação de String: o javac gera invokedynamic (StringConcatFactory). */
public class ConcatenacaoStrings {
    static String saudacao(String nome, int idade) {
        // Compilado para invokedynamic makeConcatWithConstants
        return "Olá, " + nome + "! Idade: " + idade;
    }

    public static void main(String[] args) {
        System.out.println(saudacao("Ana", 30));
    }
}
