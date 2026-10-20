package apostila.experimentos;

/** Imprime a versão da JVM que o executa e a versão do próprio class file. */
public class VersaoClasse {
    public static void main(String[] args) throws Exception {
        try (var in = VersaoClasse.class.getResourceAsStream("VersaoClasse.class")) {
            byte[] cabecalho = in.readNBytes(8);
            int minor = ((cabecalho[4] & 0xff) << 8) | (cabecalho[5] & 0xff);
            int major = ((cabecalho[6] & 0xff) << 8) | (cabecalho[7] & 0xff);
            System.out.println("class file " + major + "." + minor + " rodou na JVM "
                    + Runtime.version().feature());
        }
    }
}
