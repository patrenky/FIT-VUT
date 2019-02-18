package ija.model;

import java.io.Serializable;
import java.util.Stack;
import java.util.concurrent.ThreadLocalRandom;

/**
* Classic card pack, which has fixed maximum size of 52.
* Cards are put on the top and can be taken from any position.
*
* @author Adam Skurla - xskurl01
*/
public class CardDeck implements Serializable {
    private int size;
    private Card.Color color;
    private Card[] deck = new Card[52];

    /**
    * Number of cards is 0 - empty pack.
    */
    public CardDeck() {
        this.size = 0;
    }

    /**
    * Insert card at the top of pack, returns success of operation.
    * @param card inserted card
    * @return success of operation
    */
    public boolean put(Card card) {
        if (size < 52) {
            deck[size] = card;
            size++;
            return true;
        }
        return false;

    }

    /**
    * Removes card on given index, and returns it.
    * @param index index of card to be removed
    * @return removed card
    */
    public Card get(int index) {
        if (index > size-1 || size == 0 || index < 0) {
            return null;
        }
        Card temp = deck[index];
        for(int i = index + 1; i < this.size; i++) {
            this.deck[i-1] = this.deck[i];
        }
        size--;
        return temp;
    }

    /**
    * Shuffle pack into random order.
    */
    public void mix() {
        for(int i = 0; i < 52; i++) {
            int randomNum = ThreadLocalRandom.current().nextInt(0, 51 + 1);
            swap(i, randomNum);
        }
    }

    /**
    * Swap two cards at given indexes.
    * @param index1 first index
    * @param index2 second index
    * @return success of operation
    */
    public boolean swap(int index1, int index2) {
        if ( index1 > size - 1 || index2 > size - 1 ||
                index1 < 0 || index2 < 0 || index1 == index2) {
            return false;
        }
        Card temp = deck[index1];
        deck[index1] = deck[index2];
        deck[index2] = temp;
        return true;
    }

    /**
    * Returns true, when pack is empty, otherwise false.
    * @return pack is empty
    */
    public boolean isEmpty() {
        if (size == 0) {
            return true;
        }
        return false;
    }


    /**
    * Creates standard pack with 52 cards, 13 cards of each color.
    * @return whole pack
    */
    public CardDeck createCardDeck() {
        CardDeck deck = new CardDeck();
        for (Card.Color color : Card.Color.values()) {
            for (int i = 1; i <= 13; i++) {
                deck.put(new Card(color, i));
            }
        }
        return deck;
    }

    /**
    * Returns pack in a form of stack.
    * @return stack
    */
    public Stack<Card> returnStack() {
        Stack<Card> stack = new Stack<>();
        while(!isEmpty()) {
            stack.push(get(0));
        }
        return stack;
    }

    @Override
    public String toString() {
        String result = "";
        for(int i = 0; i < size; i++) {
            result += deck[i];
        }
        return result;
    }
}
