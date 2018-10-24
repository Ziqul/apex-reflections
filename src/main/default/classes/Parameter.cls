/**
 * @author Maxim Sorokin [m.s.v.00a@gmail.com]
 */
public class Parameter {
    private Type type;
    private String name;

    public Parameter(Type type, String name) {
        this.type = type;
        this.name = name;
    }

    public Type getType() {
        return this.type;
    }

    public String getName() {
        return this.name;
    }
}
