package ija.model;

import java.io.Serializable;
import java.util.Stack;

/**
* Stack of cards, and methods on this stack.
*
* @author Adam Skurla - xskurl01
*/
public class CardStack implements Serializable {
    private Stack<Card> cardStack = new Stack<Card>();
    private String name;

    /**
    * Set name of stack.
    * @param name meno
    */
    public CardStack(String name) {
        this.name = name;
    }

    /**
    * Insert card at the top of stack.
    * @param card inserted card
    */
    public void put(Card card) {
        cardStack.push(card);
    }

    /**
    * Remove card from the top of stack.
    * @return removed card
    */
    public Card pop() {
        return cardStack.pop();
    }

    /**
    * Tries to put the given card at the top of workingPack. If
    * insertion meets the rules, returns true, otherwise false.
    * @param card inserted card
    * @return success of insertion
    */
    public boolean tryWorkingPack(Card card) {
        if (cardStack.isEmpty() && card.value() == 13) {
            return true;
        }
        if (cardStack.isEmpty() && card.value() != 13) {
             return false;
        }

        if(card.value() + 1 == cardStack.peek().value()) {
            if(!card.similarColorTo(cardStack.peek())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Tries to put the given card at the top of targetPack. If
     * insertion meets the rules, returns true, otherwise false.
     * @param card inserted card
     * @return success of insertion
     */
    public boolean tryTargetPack(Card card) {
        if (cardStack.isEmpty() && card.value() == 1) {
            return true;
        }
        if (cardStack.isEmpty() && card.value() != 1) {
            return false;
        }

        if(card.value() == cardStack.peek().value() + 1) {
            if(card.color() == cardStack.peek().color()) {
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof CardStack))
            return false;
        CardStack stack = (CardStack) obj;
        if (stack.size() != this.size()) {
            return false;
        } else {
            return this.cardStack.equals(stack.cardStack);
        }
    }

    /**
    * Returns insight on the top card of stack.
    * @return card on top
    */
    public Card peek() {
        if (cardStack.isEmpty()) {
            return null;
        }
        return cardStack.peek();
    }

    /**
    * Returns stack of cards
    * @return stack
    */
    public Stack<Card> returnStack() {
        return this.cardStack;
    }

    /**
    * Insert card at initialisation, not looking on rules,
    * card under inserted is turned face down.
    * @param card inserted card
    */
    public void set(Card card) {
        if (!isEmpty())
            cardStack.peek().turnFaceDown();
        cardStack.push(card);
        cardStack.peek().turnFaceUp();
    }

    /**
    * Returns true, when stack is empty, otherwise false.
    * @return empty stack
    */
    public boolean isEmpty() {
        return cardStack.isEmpty();
    }

    /**
    * Returns size of stack
    * @return size of stack
    */
    public int size() {
        return cardStack.size();
    }

    /**
    * Returns name of stack.
    * @return name of stack
    */
    public String name() {
        return this.name;
    }

    @Override
    public String toString() {
        return cardStack.toString();
    }
}
