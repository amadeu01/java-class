package apostila.experimentos;

import java.io.IOException;
import java.lang.classfile.ClassFile;
import java.lang.classfile.ClassModel;
import java.lang.classfile.CodeModel;
import java.lang.classfile.Instruction;
import java.lang.classfile.MethodModel;
import java.lang.classfile.Opcode;
import java.lang.classfile.attribute.CodeAttribute;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Troca, no .class de apostila.bytecode.VerificacaoTipos, o aload_1 do
 * offset 6 de combinar() por iload_1 (0x2b por 0x1b). O resultado lê como
 * int o slot 1, que guarda uma String: o verificador tem de recusá-lo.
 * Uso: java CorrompeVerificacao.java <entrada.class> <saida.class>
 */
public class CorrompeVerificacao {
    static final String METODO = "combinar";
    static final int OFFSET = 6;

    public static void main(String[] args) throws IOException {
        byte[] bytes = Files.readAllBytes(Path.of(args[0]));
        ClassModel classe = ClassFile.of().parse(bytes);
        MethodModel metodo = classe.methods().stream()
                .filter(m -> m.methodName().equalsString(METODO))
                .findFirst().orElseThrow();
        CodeModel codigo = metodo.code().orElseThrow();

        // Confere, pelo modelo da ClassFile API, que no offset 6 está o aload_1.
        int offset = 0;
        Opcode noOffset = null;
        for (var elemento : codigo) {
            if (elemento instanceof Instruction instrucao) {
                if (offset == OFFSET) noOffset = instrucao.opcode();
                offset += instrucao.sizeInBytes();
            }
        }
        if (noOffset != Opcode.ALOAD_1) {
            throw new IllegalStateException("offset " + OFFSET + " tem " + noOffset);
        }

        // Acha o array code do método no arquivo e troca um único byte.
        byte[] code = ((CodeAttribute) codigo).codeArray();
        int inicio = procura(bytes, code);
        bytes[inicio + OFFSET] = (byte) Opcode.ILOAD_1.bytecode();
        Files.write(Path.of(args[1]), bytes);
        System.out.printf("%s()@%d: aload_1 (0x2b) -> iload_1 (0x1b)%n", METODO, OFFSET);
    }

    // Posição única de agulha em palheiro; falha se houver zero ou mais de uma.
    static int procura(byte[] palheiro, byte[] agulha) {
        int achado = -1;
        for (int i = 0; i + agulha.length <= palheiro.length; i++) {
            if (java.util.Arrays.equals(palheiro, i, i + agulha.length, agulha, 0, agulha.length)) {
                if (achado >= 0) throw new IllegalStateException("array code repetido no arquivo");
                achado = i;
            }
        }
        if (achado < 0) throw new IllegalStateException("array code não encontrado");
        return achado;
    }
}
