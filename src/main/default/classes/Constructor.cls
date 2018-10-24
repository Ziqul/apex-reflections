/**
 * @author Maxim Sorokin [m.s.v.00a@gmail.com]
 */
public class Constructor {
    private List<Parameter> params = new List<Parameter>();

    public Constructor(List<Parameter> params) {
        this.params = params;
    }

    public List<Parameter> getParams() {
        return this.params;
    }
}
