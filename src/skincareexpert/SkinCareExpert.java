package skincareexpert;

import jess.JessException;
import jess.Rete;
import jess.Value;

/**
 *
 * @author vijani
 */
public class SkinCareExpert {

    public static void main(String[] args) throws JessException {
        String path = "/home/vijani/NetBeansProjects/SkinCareExpert/clips/skin.clp";
        Rete r = new Rete();
        r.batch(path);
        r.reset();
        r.executeCommand("(focus startup)");
        r.run();
        r.executeCommand("(focus interview)");
        r.run();
        r.executeCommand("(focus recommend)");
        r.run();
        r.executeCommand("(focus report)");
        r.run();
       
    }

}
