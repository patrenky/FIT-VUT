package ija.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

/**
* Retention of history, and operations above these
* records.
*
* @author Adam Skurla xskurl01
*/
public class History implements Serializable {
    List<Object[]> history;

    /**
    * Initialisation of list containing records.
    */
    public History() {
        history = new ArrayList<Object[]>();
    }

    /**
    * Create new record.
    * @param source from where
    * @param target whereto
    * @param cards card/s, which were moved
    */
    public void makeNote(String source, String target, Stack<Card> cards) {
        Object[] note = new Object[3];
        note[0] = source;
        note[1] = target;
        note[2] = cards;

        history.add(0, note);
        toString();

        if (history.size() == 6) {
            history.remove(5);
        }
    }

    /**
    * Returns name of source of latest operation.
    * @return name of source
    */
    public String source() {
        return (String) history.get(0)[0];
    }

    /**
     * Returns name of target of latest operation.
     * @return name of target
     */
    public String target() {
        return (String) history.get(0)[1];
    }

    /**
    * Returns cards moved in latest operation.
    * @return cards
    */
    public Stack<Card> cards() {
        return (Stack<Card>) history.get(0)[2];
    }

    @Override
    public String toString() {
        if (history.get(0) != null && source() != "openCard" && source() != "allToClosed") {
            String result = "Krok: " + history.get(0)[0] + ", " + history.get(0)[1] + ", " + history.get(0)[2].toString();
            System.out.println(result);
            return result;
        }
        return "none";
    }

    /**
    * Removes latest record
    */
    public void removeLatest() {
        history.remove(0);
    }

    /**
    * Returns true if there are no records, otherwise false.
    * @return no records
    */
    public boolean isEmpty() {
        return history.isEmpty();
    }
}
